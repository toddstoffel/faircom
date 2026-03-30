#!/bin/sh
cat <<'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 FairCom Edge — Evaluation Build
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [!] EVALUATION LICENSE — 3-HOUR RUNTIME LIMIT
    This build will automatically stop after 3 hours. Restart the container
    to resume. For production use, contact FairCom for a full license.

 [+] License agreement:
    https://552967.fs1.hubspotusercontent-na1.net/hubfs/552967/V5_FairCom_Edge_Dev_260212.pdf

    By starting this container you agree to the terms of that license.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

exec "$@"
