# tcc-frontend

Dashboard do TCC — Sistema Inteligente para Licitações.

Angular + Material + ECharts. Consome o `tcc-api` por HTTP.
Cinco telas: visão geral, consulta, análise histórica, previsões e anomalias.

## Requisitos

- Node 22+
- `tcc-api` no ar

## Uso

```bash
npm install
npm run sync:api    # gera o cliente HTTP a partir do openapi.json
npm start
```

O cliente em `src/app/core/api/` é gerado. Não editar à mão.

## Documentação

`../brain/content/20_Projects/tcc-licitacoes.md`.
