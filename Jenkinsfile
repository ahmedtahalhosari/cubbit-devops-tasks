pipeline {
  agent any

  stages {
    stage('NPM Build & Test') {
      agent { 
        docker {
          image 'registry/node:14.16.0'
          args '-u root -v /var/run/docker.sock:/var/run/docker.sock -e http_proxy=http://isp-ceg.emea.grp:3128 -e https_proxy=http://isp-ceg.emea.grp:3128"'
        }
      }
      when {
              expression { BRANCH_NAME ==~ /(devops|develop|feature.*|release.*|hotfixes.*|master|PR.*|bugfix.*)/ }
            }
        steps {
            script {
                sh '''
                    node -v
                    npm -v
                    npm install
                    npm run build
                   
                '''  
            }             
        }
    }
    stage('Docker Image Build') {
      when {
        expression { BRANCH_NAME ==~ /(devops|develop|release.*|master)/ }
      }
        steps {
            script {
                version = sh(returnStdout: true, script: "cat package.json | grep version | head -1 | awk -F: '{ print \$2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]'").trim()
                timestamp=sh(script: 'date "+%Y%m%d%H%M%S"',  returnStdout: true).trim()
                docker.withRegistry('https://artifactory-chs-swf.com', 'registry') {
            def image = docker.build("docker-snapshots-local/image-compressor:${BRANCH_NAME}-${version}-${timestamp}", "-f Dockerfile .")
            image.push()
                }
            }
        }
    }
		stage("Deploy to environment"){
			when {
        expression { BRANCH_NAME ==~ /(devops|develop|release.*|master)/ }
      }
			steps{
				script{
          namespace=Getnamespace(BRANCH_NAME)
          withKubeConfig([credentialsId: 'ccs2-chs-crx-preprod', serverUrl: 'https://k8s-eb.cegedim.cloud/k8s/clusters/c-xm6hg']) {
            sh "kubectl set image deployment 	image-compressor  image-compressor=artifactory-chs-swf.com/docker-snapshots-local/image-compressor:${BRANCH_NAME}-${version}-${timestamp} --namespace ${namespace}"
            sh "kubectl rollout status deployment frontend --namespace ${namespace} --timeout=5m"
          }
        }
			}
    }
	
	}
       post { 
        always { 
            cleanWs()
        }
    }
}

def Getnamespace(branch){
   if (branch ==~ /(devops)/) {
        return 'test-devops'
     }
     if (branch ==~ /(develop)/) {
        return 'test-develop'
     }
     else if (branch ==~ /(release.*)/) {
        return 'test-test'
     }
    
}