# seccom-freq
Aplicação web para registro de frequência dos participantes no evento SECCOM. Este evento é organizado pelo grupo PET dos cursos de Ciências da Computação e Sistemas de Informação da UFSC.

## Linguagens e tecnologias usadas

### No Lado Servidor
Servidor Linux Ubuntu com:

* banco de dados [Apache Derby] (https://db.apache.org/derby/) 
* linguagem [Java] (http://www.oracle.com/technetwork/java/javase/downloads/index.html) (usando apenas servlets)
* servidor [Apache Tomcat] (http://tomcat.apache.org/)

### No Lado Cliente
Qualquer navegador (browser) com:

* Linguagem [Elm] (http://elm-lang.org/) (que compila para Javascript)


## Configurando o lado servidor
Para colocar a aplicação no ar é preciso fazer algumas instalações e configurações no lado servidor. 
Atenção: todas as variáveis de ambiente criadas devem fazer parte do $PATH. No arquivo **.profile** adicione, além das variáveis criadas a linha:

```
export PATH=$JAVA_HOME/bin:$DERBY_HOME/bin:$TOMCAT_HOME/bin:$PATH
```

### Instalar a JVM
Instalar a JVM da maneira habitual. Deve ser a Java SE SDK versão 8 por causa da versão usada no Tomcat. Defina no arquivo **.profile** a variável de ambiente **JAVA_HOME** apontando para o diretório onde a JVM foi instalada.

### Instalar o Derby
Instalar o Derby da maneira habitual. Defina no arquivo **.profile** as variáveis de ambiente **DERBY_HOME** e **DERBY_OPTS** que devem, respectivamente, apontar para o diretório onde o Derby foi instalado e conter o valor **"-Xms50m -Xmx50m"** (exemplo: export DERBY_OPTS="-Xms50m -Xmx50m"). Com isso a JVM do banco só ocupara 50MB de memória.

### Instalar o Tomcat
Instalar o Tomcat da maneira habitual. Defina no arquivo **.profile** a variável de ambiente **TOMCAT_HOME** que deve apontar para o diretório onde o Tomcat foi instalado.

Depois de instalado, o Tomcat precisa ser configurado para: a) só aceitar requisições que usem o protocolo HTTPS via porta 8443, garantindo mais segurança nas informações trocadas entre o cliente e o servidor; b) poder se comunicar com o Derby (via driver JDBC)

#### HTTPS via porta 8843

Digite o comando abaixo para gerar um certificado que será armazenado no arquivo **~/.keystore**. Não esqueça a senha que você fornecer quando for solicitado (exemplo : s3cr3ta)

```bash
 keytool -genkey -alias tomcat -keyalg RSA
```
Edite o arquivo **conf/server.xml** do Tomcat e localize a tag **``<Service name="Catalina">``**. Adicione dentro desta tag o seguinte código XML (o exemplo usa a senha s3cr3ta):

```xml
<Connector 
    port="8443" 
    protocol="org.apache.coyote.http11.Http11NioProtocol"
    maxThreads="150" 
    SSLEnabled="true" 
    scheme="https" 
    secure="true" 
    keystorefile="${user.home}/.keystore" 
    keystorePass="s3cr3ta">
</Connector>
```

#### Instalando driver JDBC do derby
Copie os arquivos **derbyclient.jar** e todos os arquivos **derbyLocale_XX.jar** que estão em **DERBY_HOME/lib** para dentro do Tomcat (em **TOMCAT_HOME/lib**). Exemplo:

```
cp $DERBY_HOME/lib/derbyclient.jar $TOMCAT_HOME/lib
cp $DERBY_HOME/lib/derbyLocale*.jar $TOMCAT_HOME/lib
```

## Criando da Base de dados
Agora que está tudo instalado e configurado é preciso criar a base de dados usada pela aplicação.

Crie um diretório onde o banco de dados será armazenado e coloque o Derby no ar executando:

```
mkdir bases
cd bases
startNetworkServer -p 1300 &
```

Para criar a base de dados edite o arquivo **cria_banco.sql** e substitua as palavras *usuario1* e *senha1* por um nome de usuário e senha que só você conheça. Em seguida execute

```
ij cria_banco.sql
```
Será criado, dentro do diretório *bases* o diretório **SECCOM_FREQ** que contém a base de dados que acabou de ser criada. Para backup desta base de dados, basta copiar o conteúdo do diretório.

Agora é preciso criar as tabelas que armazenarão os dados da aplicação. Edite o arquivo **cria_tabelas.sql**, substitua as palavaras *usuario1* e *senha1* pelos nomes que você colocou no arquivo *cria_banco.sql* e, em seguida execute

```
ij cria_tabelas.sql
```






