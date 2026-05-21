{{/*
MDS resource full name
*/}}
{{- define "mds.fullname" -}}
{{- $name := include "lakefs.fullname" . }}
{{- printf "%s-mds" $name  | trunc 63 }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mds.labels" -}}
helm.sh/chart: {{ include "lakefs.chart" . }}
{{ include "mds.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mds.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lakefs.name" . }}-mds
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: mds
app: {{ include "lakefs.name" . }}-mds
{{- end }}

{{/*
MDS image repository. Defaults to the lakeFS Enterprise image, which ships
the `lakefs mds` subcommand. To roll back to the legacy standalone MDS
container, override `mds.image.repository` (and typically `mds.image.tag`
and `mds.args` / `mds.command`) in values.
*/}}
{{- define "mds.repository" -}}
{{- default "treeverse/lakefs-enterprise" .Values.mds.image.repository -}}
{{- end }}

{{/*
MDS image tag. Explicit `mds.image.tag` wins; otherwise reuse the chart's
enterprise tag so the MDS pod tracks the lakeFS server version by default.
*/}}
{{- define "mds.tag" -}}
{{- if .Values.mds.image.tag -}}
{{- .Values.mds.image.tag -}}
{{- else -}}
{{- required "image.enterprise.tag is required when mds.enabled is true and mds.image.tag is unset" (((.Values.image).enterprise).tag) -}}
{{- end -}}
{{- end }}

{{/*
MDS volumes
*/}}
{{- define "mds.volumes" -}}
- name: {{ include "mds.fullname" . }}-config
  configMap:
    name: {{ include "mds.fullname" . }}-config
    items:
      - key: config.yaml
        path: config.yaml
{{- if (.Values.enterprise).enabled }}
{{- if and .Values.existingSecret .Values.secretKeys.licenseContentsKey }}
- name: secret-volume-license-token
  secret:
    secretName: {{ .Values.existingSecret }}
    items:
      - key: {{ .Values.secretKeys.licenseContentsKey }}
        path: license.tkn
{{- else if and .Values.secrets .Values.secrets.licenseContents }}
- name: secret-volume-license-token
  secret:
    secretName: {{ include "lakefs.fullname" . }}
    items:
      - key: license_contents
        path: license.tkn
{{- end }}
{{- end }}
{{ with .Values.mds.extraVolumes -}}
{{- toYaml . }}
{{- end -}}
{{- end }}

{{/*
MDS volume mounts
*/}}
{{- define "mds.volumeMounts" -}}
- name: {{ include "mds.fullname" . }}-config
  mountPath: /app/config.yaml
  subPath: config.yaml
{{- if (.Values.enterprise).enabled }}
{{- if or (and .Values.secrets .Values.secrets.licenseContents) (and .Values.existingSecret .Values.secretKeys.licenseContentsKey) }}
- name: secret-volume-license-token
  mountPath: /etc/lakefs/license.tkn
  subPath: license.tkn
  readOnly: true
{{- end }}
{{- end }}
{{ with .Values.mds.extraVolumeMounts -}}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
MDS environment variables. The `lakefs mds run` subcommand opens the KV
store, builds the catalog, and validates the license against the same
configuration the lakeFS server reads, so MDS gets the shared secret env
vars from `lakefs.sharedSecretEnv`.
*/}}
{{- define "mds.env" -}}
env:
  {{- include "lakefs.sharedSecretEnv" . | nindent 2 }}
  {{- with .Values.mds.extraEnvVars }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- if .Values.mds.extraEnvVarsSecret }}
envFrom:
  - secretRef:
      name: {{ .Values.mds.extraEnvVarsSecret }}
{{- end }}
{{- end }}
