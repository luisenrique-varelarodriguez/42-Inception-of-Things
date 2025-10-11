#!/bin/sh

# Load logging functions
. "$(dirname "$0")/logging.sh"

log_header "60" "Configuring port-forwards loops"

# Kill previous port-forwards if they exist
log_info "Cleaning existing port-forwards"
pkill kubectl >/dev/null 2>&1 || true
log_success "Previous port-forwards terminated"

# Port-forward with automatic retries in loop
log_info "Starting port-forwards loops"

(while true; do 
  kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8081:80 >/dev/null 2>&1
  sleep 2
done) &

(while true; do 
  kubectl port-forward svc/gitlab-webservice-default -n gitlab --address 0.0.0.0 8082:8181 >/dev/null 2>&1
  sleep 2
done) &

(while true; do 
    if kubectl get svc wil42-service -n dev >/dev/null 2>&1; then
        kubectl port-forward svc/wil42-service -n dev --address 0.0.0.0 8083:8888 >/dev/null 2>&1
    fi
    sleep 5
done) &

log_success "Port-forwards loops configured successfully"

sleep 2

# Credentials and access
GITLAB_PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "ERROR_GETTING_PASSWORD")

echo
echo "--------------------------------------------"
echo "           ArgoCD Access Details            "
echo "--------------------------------------------"
echo "  External URL (host):  http://localhost:18081"
echo "  Username:             admin"
echo "  Password:             holasoyadmin"
echo "--------------------------------------------"
echo
echo "--------------------------------------------"
echo "           GitLab Access Details            "
echo "--------------------------------------------"
echo "  External URL (host):  http://localhost:18082"
echo "  Username:             root"
echo "  Password:             $GITLAB_PASSWORD"
echo "--------------------------------------------"
echo
echo "--------------------------------------------"
echo "           App wil42 Access Details         "
echo "--------------------------------------------"
echo "  External URL (host):  http://localhost:18083"
echo "--------------------------------------------"
echo

log_info "Port-forwards will automatically reconnect if lost"
log_warning "To stop all port-forwards: pkill kubectl"