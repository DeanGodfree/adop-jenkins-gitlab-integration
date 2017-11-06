/**
 * Author: john.bryan.j.sazon@accenture.com
 */

import jenkins.model.*
import hudson.util.Secret;
import com.cloudbees.plugins.credentials.SystemCredentialsProvider;
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl;
import com.cloudbees.plugins.credentials.CredentialsScope;

// Check if enabled
def env = System.getenv()
if (!env['ADOP_GITLAB_ENABLED'].toBoolean()) {
    println "--> ADOP Gitlab Disabled"
    return
}
def username = env['GITLAB_ADMIN_USER'] ?: 'root'
def password = env['GITLAB_ADMIN_PASSWORD']

if (!password) {
    println "GITLAB_ADMIN_PASSWORD is empty, Gitlab credentials setup will not proceed."
    return
}

def instance = Jenkins.getInstance()

Thread.start {
    sleep 9000

    def credentialDescription = "Gitlab Administrator Credentials"
    def credentialsId = "gitlab-admin-credentials"
    def systemCredentialsProvider = SystemCredentialsProvider.getInstance()
    def credentialScope = CredentialsScope.GLOBAL
    def credentialDomain = com.cloudbees.plugins.credentials.domains.Domain.global()
    def credentialToCreate = new UsernamePasswordCredentialsImpl(credentialScope, credentialsId, credentialDescription, username, password)

    def credentialsFound = false
    systemCredentialsProvider.getCredentials().each {
    credentials = (com.cloudbees.plugins.credentials.Credentials) it
        if (credentials.getDescription() == credentialDescription) {
            println "Found existing credentials: " + credentialDescription
            credentialsFound = true
        }
    }

    /**
     * Create the credentials
     */
    if (!credentialsFound) {
        println "--> Registering ${credentialDescription}.."
        systemCredentialsProvider.addCredentials(credentialDomain,credentialToCreate)
        println credentialDescription + " created.."
    }

    instance.save()
}
