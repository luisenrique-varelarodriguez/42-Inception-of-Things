#!/bin/sh

echo "[60] Configurando port-forwards con auto-reconexión..."

# Matar port-forwards anteriores si existen
pkill kubectl >/dev/null 2>&1 || true

# Port-forward con reintentos automáticos en bucle
(while true; do kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8081:80; sleep 2; done) &
(while true; do kubectl port-forward svc/gitlab-webservice-default -n gitlab --address 0.0.0.0 8082:8181; sleep 2; done) &

# Para la app, esperar a que exista el service
(while true; do 
    if kubectl get svc wil42-service -n dev >/dev/null 2>&1; then
        kubectl port-forward svc/wil42-service -n dev --address 0.0.0.0 8083:8888
    fi
    sleep 5
done) &

sleep 2

echo ""
echo "Port-forwards configurados con auto-reconexión:"
echo "   - ArgoCD:  http://localhost:18081"
echo "   - GitLab:  http://localhost:18082"  
echo "   - App:     http://localhost:18083"
echo ""
echo "Se reconectarán automáticamente si se pierden."
echo "Para parar: pkill kubectl"
