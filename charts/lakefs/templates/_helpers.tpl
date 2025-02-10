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
2. Otherwise if fluffy is enabled - take enterprise image
3. Otherwise use OSS image
*/}}
{{- define "lakefs.repository" -}}
{{- if not .Values.image.repository }}
{{- if (.Values.fluffy).enabled  }}
{{- default "treeverse/lakefs-enterprise" .Values.image.repository }}
{{- else }}
{{- default "treeverse/lakefs" .Values.image.repository }}
{{- end }}
{{- else }}
{{- default .Values.image.repository }}
{{- end }}
{{- end }}