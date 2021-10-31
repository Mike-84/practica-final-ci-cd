# Practica final CI-CD

# Requisitos

- Tener instalado java y chromedriver (la versión del chromedriver debe casar con la misma que el navegador chrome y estar instalado en el path: /usr/local/bin/chromedriver).

 - Para instalar java: https://ubunlog.com/instala-java-8-9-y-10-en-ubuntu-18-04-y-derivados/

 - Versiones del chromedriver: https://chromedriver.chromium.org/downloads y como instalarlo https://yizeng.me/2014/04/20/install-chromedriver-and-phantomjs-on-linux-mint/ en linux.

 No hace falta descargar el chromedriver para los test del Jenkinsfile ya en este caso el propio contenedor tiene instalado el chrome y el chromedriver.

 Todo se levanta de forma local usando este repositorio, los puertos son:

 ```
 |   Jenkins   localhost:8080    |
 |   Nexus     localhost:8081    |
 |   Frontend  localhost:9080    |
 |   Backend   localhost:5050    |
 |   db        localhost:3307    |
 ```

 - El docker-compose del front, back y db está en la carpeta integration.


## Configurar

 Usar `docker-compose up` o `docker-compose up -d` (segundo plano) para levantar jenkins y nexus

 Una vez se haga en docker-compose configurar jenkins y nexus para que al realizar el build en pipeline funcione todo.

## Nexus

  - Para saber la password de nexus usamos el comando `docker exec practica-final-ci-cd_nexus_1 cat /nexus-data/admin.password` y poder logearnos a nexus con el username de admin.

  - Nos pide cambiar la pass, yo la cambiaré por admin ya que es en local, y marcar Enable anonymous access.

  - Una vez dentro vamos a configuración (símbolo de la tuerca), e ir a repositorios y crear un docker (hosted) con un puerto http 8082, marcar enable docker V1 API, deployment policy en disable redeploy y marcar allow redeploy only 'latest' tag y crear.

  - Después en la misma configuración vamos a realms y activamos docker bearer token realm y guardamos, con esto está configurado nuestro nexus.

## Jenkins

  - Para saber la pass inicial de jenkins podemos usar el comando: `docker exec -u root practica-final-ci-cd_jenkins_1 cat /var/jenkins_home/secrets/initialAdminPassword` o ver los logs del contenedor con un: `docker-compose logs jenkins`

  - Nos pedira el metodo de como instalar, yo le daré a elegir los plugin y hay que añadir el de gitlab, una vez realizada la instalación de los plugins podremos mas adelante instalar el plugin de blue ocean para ver mejor los stages y demás, este plugin se debe instalar desde manage jenkins e ir a manage plugins y en el buscador poner el nombre del plugin pero este solo se puede instalar una vez configurado todo.

  - Después de instalar los plugins nos pide poner nuevo usuario password e email, de nuevo yo pondré todo admin ya que es en local.

  - Cuando ya tenemos todo configurado con plugins y demás vamos a dar new item le damos un nombre y le damos a multibranch pipeline y añadir este repositorio, le podemos dar un nombre y en  branch sources añadimos un git, ponemos el link del repositorio, añadimos en el apartado de Jenkins nuestras credenciales de gitlab, el kind tiene que ser username with password, creamos, y automáticamente buscará el jenkinsfile que hay en el repositorio y al final pondrá un Finished: SUCCESS.

  - Una vez detecte el Jenkinsfile realizará los test de frontend y backend automáticamente y si todo funciona correctamente nos podremos ir al nexus y ver en browse las imagenes de frontend y backend guardadas, el test suele tardar varios minutos.

  - Debido a que el Jenkins es en local no se puede vincular a la cuenta de gitlab en la nube entonces no se realiza el test del jenkinsfile de frma automática pero si se quedan guardados los commits, solo hay que darle a build now.


  - Para realizar el test behave hay que hacerlo manualmente dentro de la carpeta integration y realizar un `docker-compose up -d` para levantar la página con su base de datos aquí se requiere el chromedriver y virtualenv y un `docker-compose -f logs`

     - Una vez levantado el contenedor realizamos los siguientes comandos:

     ```
     virtualenv .env python3
     . .env/bin/activate
     pip install -r requirements.txt
     behave
     ```
     - Al realizar estos comandos en los logs nos saldrá un mensaje:

   ```
   Feature: shopping ACME stuff # features/shopping.feature:1

     Background: go to main site  # features/shopping.feature:3

     Scenario: count number of items  # features/shopping.feature:6
       Given We are in the main site  # features/steps/shopping.py:6 0.382s
       Then 3 items must be displayed # features/steps/shopping.py:11 0.052s

     Scenario Outline: list current items -- @1.1 Items  # features/shopping.feature:14
       Given We are in the main site                     # features/steps/shopping.py:6 0.093s
       Then "cohete" item must be displayed              # features/steps/shopping.py:17 0.058s

     Scenario Outline: list current items -- @1.2 Items  # features/shopping.feature:15
       Given We are in the main site                     # features/steps/shopping.py:6 0.057s
       Then "dinamita" item must be displayed            # features/steps/shopping.py:17 0.095s

     Scenario Outline: list current items -- @1.3 Items  # features/shopping.feature:16
       Given We are in the main site                     # features/steps/shopping.py:6 0.059s
       Then "yunque" item must be displayed              # features/steps/shopping.py:17 0.126s

     Scenario: shop item                                          # features/shopping.feature:18
       Given We are in the main site                              # features/steps/shopping.py:6 0.077s
       Then We want to buy a "cohete" with "coyote@acme.es" email # features/steps/shopping.py:23 2.952s

   1 feature passed, 0 failed, 0 skipped
   5 scenarios passed, 0 failed, 0 skipped
   10 steps passed, 0 failed, 0 skipped, 0 undefined
   ```

## Cosas a mejorar o que faltan

  - El cambio de versión automático desde el Jenkinsfile, no logré que detectase el archivo version del frontend y el backend y si haces varios build now dará error en la parte del test `publicar imagen` ya que la versión que se sube siempre es la misma, y lo que se debe hacer para remediarlo es: o bien borrar las imagenes en el browse de nexus o cambiar la version en el Jenkinsfile.

  - El behave quizás no se pueda hacer desde un jenkins en local ya que están en contenedores separados con el compose que se levanta de la carpeta intagration.


## Cosas que he hecho para la práctica final

   - Para que al final realizase esta práctica estuve probando con dos repositorios independientes, propios, uno de [frontend](https://gitkc.cloud/Mike/prueba-jenkins-frontend-local) y otro de [backend](https://gitkc.cloud/Mike/prueba-jenkins-backend-local) y en ambos hay alguna imagen de todos los intentos que he tenido para que el Jenkinsfile funcionase.
