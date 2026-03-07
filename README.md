docker run -d `
  --name n8n-runners `
  --network n8n-net `
  -e N8N_RUNNERS_AUTH_TOKEN=mysecrettoken `
  n8nio/runners:latest

docker run -d `
  --name n8n `
  --network n8n-net `
  -p 5678:5678 `
  -e N8N_RUNNERS_ENABLED=true `
  -e N8N_RUNNERS_MODE=external `
  -e N8N_RUNNERS_AUTH_TOKEN=mysecrettoken `
  -e N8N_RUNNERS_TASK_BROKER_URI=ws://n8n:5678 `
  -v n8n:/home/node/.n8n `
  n8nio/n8n:latest