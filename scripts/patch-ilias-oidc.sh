#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

target="src/components/ILIAS/OpenIdConnect/classes/class.ilAuthProviderOpenIdConnect.php"

if [[ ! -f "${target}" ]]; then
  echo "Missing ${target}. Run ./scripts/bootstrap.sh after cloning ILIAS source." >&2
  exit 1
fi

if grep -q 'KEYCLOAK_INTERNAL_ISSUER' "${target}"; then
  exit 0
fi

perl -0pi -e 's#(\$oidc = new OpenIDConnectClient\(\n\s+\$this->settings->getProvider\(\),\n\s+\$this->settings->getClientId\(\),\n\s+\$this->settings->getSecret\(\)\n\s+\);\n)#$1 . q{
        $internalIssuer = getenv("KEYCLOAK_INTERNAL_ISSUER") ?: "";
        if ($internalIssuer !== "") {
            $publicIssuer = rtrim($this->settings->getProvider(), "/");
            $internalIssuer = rtrim($internalIssuer, "/");
            $oidc->setProviderURL($internalIssuer);
            $oidc->setIssuer($publicIssuer);
            $oidc->providerConfigParam([
                "issuer" => $publicIssuer,
                "authorization_endpoint" => $publicIssuer . "/protocol/openid-connect/auth",
                "end_session_endpoint" => $publicIssuer . "/protocol/openid-connect/logout",
                "token_endpoint" => $internalIssuer . "/protocol/openid-connect/token",
                "userinfo_endpoint" => $internalIssuer . "/protocol/openid-connect/userinfo",
                "jwks_uri" => $internalIssuer . "/protocol/openid-connect/certs",
            ]);
        }

}#e' "${target}"
