docker run -d `
  --name n8n `
  --network n8n-net `
  -p 5678:5678 `
  -p 5679:5679 `
  -e N8N_RUNNERS_ENABLED=true `
  -e N8N_RUNNERS_MODE=external `
  -e N8N_RUNNERS_AUTH_TOKEN=mysecrettoken `
  -e N8N_RUNNERS_BROKER_LISTEN_ADDRESS=0.0.0.0 `
  -v n8n_data:/home/node/.n8n `
  n8nio/n8n:latest

docker run -d `
  --name n8n-runners `
  --network n8n-net `
  -e N8N_RUNNERS_AUTH_TOKEN=mysecrettoken `
  -e N8N_RUNNERS_TASK_BROKER_URI=http://n8n:5679 `
  n8nio/runners:latest