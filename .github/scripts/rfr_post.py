#!/usr/bin/env python3
"""Post a PR that is ready for review to a Slack channel, and keep it current.

Runs from a pull_request workflow and reads the event payload.  One message per
PR: the first run posts it, later runs edit it so the reviewer mentions match
GitHub.  The message is found again through Slack message metadata, which also
records the reviewers it last named, so nothing is stored outside Slack.  A
reviewer added later, or asked to review again, is pinged in the message's
thread, since an edit sends no notification.

Configuration comes from environment variables (see the workflow file).  Exits
non-zero on API or Slack failure so the Action surfaces a red run.
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime
from typing import Any

SLACK_API = "https://slack.com/api"
GITHUB_API = "https://api.github.com"
USER_AGENT = "rfr-post"
METADATA_EVENT_TYPE = "rfr_pr"

# conversations.history pages, bounded below by the PR's creation time.
HISTORY_PAGE = 200
HISTORY_MAX_PAGES = 10

# Pages of the PR's submitted reviews.
REVIEWS_PAGE = 100
REVIEWS_MAX_PAGES = 10


def env(name: str, default: str | None = None) -> str:
    value = os.environ.get(name, default)
    if value is None:
        sys.exit(f"Missing required environment variable: {name}")
    return value


def env_bool(name: str, default: bool) -> bool:
    return os.environ.get(name, str(default)).strip().lower() in ("1", "true", "yes")


def load_event() -> dict:
    with open(env("GITHUB_EVENT_PATH"), encoding="utf-8") as handle:
        return json.load(handle)


def load_user_map(path: str) -> dict[str, str]:
    """Return GitHub login to Slack user id, with logins lower-cased.

    The mapping is the JSON in the USER_MAP_JSON environment variable when that
    is set, otherwise the JSON file at `path`.  With neither, it is empty.
    """
    inline = os.environ.get("USER_MAP_JSON", "").strip()
    if inline:
        try:
            mapping = json.loads(inline)
        except json.JSONDecodeError as error:
            sys.exit(f"USER_MAP_JSON is not valid JSON: {error}")
    else:
        try:
            with open(path, encoding="utf-8") as handle:
                mapping = json.load(handle)
        except FileNotFoundError:
            print(f"No USER_MAP_JSON and no user map at {path}; reviewers are named as plain text.")
            return {}
    return {login.lower(): user_id for login, user_id in mapping.items()}


def escape_slack(text: str) -> str:
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def mention(login: str, user_map: dict[str, str]) -> str:
    user_id = user_map.get(login.lower())
    return f"<@{user_id}>" if user_id else escape_slack(login)


def reviewer_keys(pull_request: dict) -> list[str]:
    """Return the requested reviewers as stable keys: a login, or `team:<slug>`."""
    keys = [user["login"] for user in pull_request.get("requested_reviewers", [])]
    keys.extend(f"team:{team['slug']}" for team in pull_request.get("requested_teams", []))
    return keys


def mention_key(key: str, user_map: dict[str, str]) -> str:
    if key.startswith("team:"):
        return f"@{key[len('team:'):]}"
    return mention(key, user_map)


def build_text(repo: str, pull_request: dict, keys: list[str], user_map: dict[str, str]) -> str:
    title = escape_slack(pull_request["title"])
    author = mention(pull_request["user"]["login"], user_map)
    asked = ", ".join(mention_key(k, user_map) for k in keys) if keys else "_no reviewer requested yet_"
    return (
        f":eyes: <{pull_request['html_url']}|{title}>  `{repo}#{pull_request['number']}`\n"
        f"by {author} · reviewers: {asked}"
    )


def fetch_json(request: urllib.request.Request, service: str) -> Any:
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        detail = error.read().decode("utf-8", "replace")[:500]
        sys.exit(f"{service} API {error.code} on {request.full_url}: {detail}")
    except urllib.error.URLError as error:
        sys.exit(f"Could not reach {service}: {error.reason}")


def slack_call(method: str, token: str, body: dict[str, Any]) -> dict:
    request = urllib.request.Request(
        f"{SLACK_API}/{method}",
        data=json.dumps(body).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json; charset=utf-8",
            "User-Agent": USER_AGENT,
        },
    )
    payload = fetch_json(request, "Slack")

    # A rejected call still answers 200; the body is the only failure signal.
    if not payload.get("ok"):
        error = payload.get("error", "unknown")
        hint = ""
        if error in ("not_in_channel", "channel_not_found"):
            hint = " - invite the app to the channel and check SLACK_CHANNEL"
        elif error == "missing_scope":
            hint = f" - the app needs the scope {payload.get('needed', '?')}"
        sys.exit(f"Slack rejected {method}: {error}{hint}")
    return payload


def has_reviewed(token: str, repository: str, number: int, login: str) -> bool:
    """Report whether `login` has submitted a review on the PR."""
    for page in range(1, REVIEWS_MAX_PAGES + 1):
        query = urllib.parse.urlencode({"per_page": REVIEWS_PAGE, "page": page})
        request = urllib.request.Request(
            f"{GITHUB_API}/repos/{repository}/pulls/{number}/reviews?{query}",
            headers={
                "Authorization": f"Bearer {token}",
                "Accept": "application/vnd.github+json",
                "User-Agent": USER_AGENT,
            },
        )
        reviews = fetch_json(request, "GitHub")
        if any((review.get("user") or {}).get("login", "").lower() == login.lower() for review in reviews):
            return True
        if len(reviews) < REVIEWS_PAGE:
            return False
    return False


def find_message(
    token: str, channel: str, repo: str, number: int, oldest: float
) -> tuple[str, list[str]] | None:
    """Return the PR message's timestamp and the reviewer keys it last recorded.

    Walks the channel's history from `oldest` (Unix seconds) forward, matching on
    the metadata the post carries, never on the text.  Requires the
    `channels:history` scope (`groups:history` for a private channel).
    """
    cursor = None
    for _ in range(HISTORY_MAX_PAGES):
        body: dict[str, Any] = {
            "channel": channel,
            "limit": HISTORY_PAGE,
            "oldest": f"{oldest:.6f}",
            "include_all_metadata": True,
        }
        if cursor:
            body["cursor"] = cursor
        payload = slack_call("conversations.history", token, body)
        for message in payload.get("messages", []):
            metadata = message.get("metadata") or {}
            if metadata.get("event_type") != METADATA_EVENT_TYPE:
                continue
            event = metadata.get("event_payload") or {}
            if event.get("repo") == repo and str(event.get("number")) == str(number):
                return message["ts"], list(event.get("reviewers") or [])
        cursor = (payload.get("response_metadata") or {}).get("next_cursor")
        if not payload.get("has_more") or not cursor:
            break
    return None


def post_or_update(
    token: str, channel: str, repo: str, pull_request: dict, user_map: dict[str, str], rerequested: str | None
) -> None:
    """Post the PR's message, or edit the existing one.

    Slack sends no notification for an edit, so after an edit every reviewer
    not in the message's recorded set is pinged with a reply in its thread.
    `rerequested` is the login the event asked to review; when it is already
    recorded and has reviewed the PR before, it is pinged as a re-review.
    """
    number = pull_request["number"]
    keys = reviewer_keys(pull_request)
    text = build_text(repo, pull_request, keys, user_map)
    metadata = {
        "event_type": METADATA_EVENT_TYPE,
        "event_payload": {"repo": repo, "number": number, "reviewers": keys},
    }
    body: dict[str, Any] = {"channel": channel, "text": text, "metadata": metadata, "unfurl_links": False}

    if env_bool("DRY_RUN", False):
        print(f"DRY_RUN=true - not posting or updating {repo}#{number}:\n")
        print(json.dumps(body, indent=2))
        return

    created = datetime.fromisoformat(pull_request["created_at"].replace("Z", "+00:00")).timestamp()
    found = find_message(token, channel, repo, number, oldest=created)
    if not found:
        slack_call("chat.postMessage", token, body)
        print(f"Posted {repo}#{number}.")
        return

    ts, recorded = found
    slack_call("chat.update", token, {**body, "ts": ts})
    print(f"Updated the message for {repo}#{number}.")

    new = [k for k in keys if k not in recorded]
    if new:
        named = ", ".join(mention_key(k, user_map) for k in new)
        slack_call("chat.postMessage", token, {"channel": channel, "thread_ts": ts, "text": f"Review requested from {named}"})
        print(f"Replied in the thread to notify {named}.")

    # A re-request sends the same event as the first request; only the PR's
    # review history tells them apart.
    if rerequested in recorded and has_reviewed(env("GITHUB_TOKEN"), env("GITHUB_REPOSITORY"), number, rerequested):
        named = mention(rerequested, user_map)
        slack_call("chat.postMessage", token, {"channel": channel, "thread_ts": ts, "text": f"Re-review requested from {named}"})
        print(f"Replied in the thread to notify {named} of a re-review.")


def main() -> None:
    event = load_event()
    pull_request = event.get("pull_request")
    if not pull_request:
        sys.exit("The event payload has no pull_request; run this from a pull_request workflow.")

    repo = env("GITHUB_REPOSITORY").split("/", 1)[-1]
    number = pull_request["number"]

    if pull_request.get("draft"):
        print(f"{repo}#{number} is a draft; nothing to post until it is ready for review.")
        return
    if pull_request.get("state") != "open":
        print(f"{repo}#{number} is {pull_request.get('state')}; nothing to post.")
        return
    if pull_request.get("user", {}).get("type") == "Bot":
        print(f"{repo}#{number} was opened by a bot; nothing to post.")
        return

    user_map = load_user_map(env("USER_MAP", ".github/rfr-slack-users.json"))

    # A dry run never posts, so Slack credentials are optional there.
    dry_run = env_bool("DRY_RUN", False)
    token = env("SLACK_BOT_TOKEN", "" if dry_run else None)
    channel = env("SLACK_CHANNEL", "" if dry_run else None)
    rerequested = None
    if event.get("action") == "review_requested":
        rerequested = (event.get("requested_reviewer") or {}).get("login")
    post_or_update(token, channel, repo, pull_request, user_map, rerequested)


if __name__ == "__main__":
    main()
