{{- define "my-vote-api.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}
