{ pkgs }:
pkgs.writeShellApplication {
  name = "route53-ddns";

  runtimeInputs = with pkgs; [ awscli2 curl grep ];

  # source: https://www.cloudsavvyit.com/3103/how-to-roll-your-own-dynamic-dns-with-aws-route-53/
  # HOSTED_ZONE_ID="Z05070245KRBUN98XFS7"
  # NAME="nregner.net."
  text = ''
    TYPE="A"
    TTL=300

    # get current IP address
    IP=$(curl --silent --show-error --fail http://checkip.amazonaws.com/)

    # get current records
    aws route53 list-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" \
      --query "ResourceRecordSets[?Name==\`$NAME\` && Type == \`$TYPE\`].ResourceRecords[].Value | [0]" \
      --output text \
      >/tmp/current_route53_value

    cat /tmp/current_route53_value

    # check if IP is different from Route 53
    if grep -Fxq "$IP" /tmp/current_route53_value; then
      echo "IP has not changed, exiting..."
      exit 0
    fi

    echo "IP changed, updating records..."

    #prepare route 53 payload
    cat >/tmp/route53_changes.json <<EOF
      {
        "Comment": "Updated From DDNS Shell Script",
        "Changes": [
          {
            "Action": "UPSERT",
            "ResourceRecordSet": {
              "ResourceRecords": [
                { "Value": "$IP" }
              ],
              "Name": "$NAME",
              "Type": "$TYPE",
              "TTL": $TTL
            }
          }
        ]
      }
    EOF

    aws route53 change-resource-record-sets \
      --hosted-zone-id "$HOSTED_ZONE_ID" \
      --change-batch file:///tmp/route53_changes.json \
      >>/dev/null
  '';
}
