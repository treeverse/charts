{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "lakefs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "lakefs.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "lakefs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "lakefs.labels" -}}
helm.sh/chart: {{ include "lakefs.chart" . }}
{{ include "lakefs.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "lakefs.selectorLabels" -}}
app: {{ include "lakefs.name" . }}
app.kubernetes.io/name: {{ include "lakefs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "lakefs.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "lakefs.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define which repository to use according to the following:
1. Explicitly defined
2. Otherwise if enterprise is enabled - take enterprise image
3. Otherwise use OSS image
*/}}
{{- define "lakefs.repository" -}}
{{- if not .Values.image.repository }}
{{- if (.Values.enterprise).enabled }}
{{- default "treeverse/lakefs-enterprise" .Values.image.repository }}
{{- else }}
{{- default "treeverse/lakefs" .Values.image.repository }}
{{- end }}
{{- else }}
{{- default .Values.image.repository }}
{{- end }}
{{- end }}

{{- define "lakefs.checkDeprecated" -}}
{{- if .Values.fluffy -}}
{{- fail "Fluffy configuration detected. Please migrate to lakeFS Enterprise auth configuration and use treeverse/lakefs-enterprise docker image. See migration guide: https://docs.lakefs.io/latest/enterprise/upgrade/#kubernetes-migrating-with-helm-from-fluffy-to-new-lakefs-enterprise." -}}
{{- end -}}
{{- end -}}

{{- define "lakefs.dockerConfigJson" }}
{{- $token := .Values.image.privateRegistry.secretToken }}
{{- $username := "externallakefs" }}
{{- $registry := "https://index.docker.io/v1/" }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"auth\":\"%s\"}}}" $registry $username $token (printf "%s:%s" $username $token | b64enc) | b64enc }}
{{- end }}
