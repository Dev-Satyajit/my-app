package com.ssinha.common.config;

import com.azure.core.credential.TokenCredential;
import com.azure.identity.ClientSecretCredentialBuilder;
import com.azure.security.keyvault.secrets.SecretClient;
import com.azure.security.keyvault.secrets.SecretClientBuilder;
import com.azure.security.keyvault.secrets.models.KeyVaultSecret;
import com.ssinha.common.util.Utils;

public class KeyVaultSecretAccess {

	private final SecretClient secretClient;

	public KeyVaultSecretAccess(String endpoint, String tenant, String clientId, String clientSecret) {
		final TokenCredential credential = new ClientSecretCredentialBuilder()
				.clientId(clientId)
				.clientSecret(clientSecret)
				.tenantId(tenant)
				.additionallyAllowedTenants("*")
				.build();
		this.secretClient = new SecretClientBuilder().vaultUrl(endpoint).credential(credential).buildClient();
	}

	public String getSecretValue(String key) {
		return getKeyVaultSecret(key, null).getValue();
	}

	private KeyVaultSecret getKeyVaultSecret(String key, String version) {
		KeyVaultSecret secret = null;
		try {
			secret = !Utils.isEmpty(version) ? this.secretClient.getSecret(key) : this.secretClient.getSecret(key, version);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return secret;
	}
}
