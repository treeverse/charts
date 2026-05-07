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
{{ with .Values.mds.extraVolumeMounts -}}
{{- toYaml . }}
{{- end }}
{{- end }}
