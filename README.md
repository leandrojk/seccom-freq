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
* [Bulma] (http://bulma.io/) (estilos CSS)


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
Criadas as tabelas, é preciso povoar o banco com os dados da semana, das palestras e dos estudantes. Analise o conteúdo do arquivo **cria_dados.sql** e veja como inserir os dados nas respectivas tabelas. **ATENÇÃO:** o arquivo atual apaga todos os dados atualmente armazenados nas tabelas. A sugestão é criar, a partir do arquivo, outros com objetivos bem específicos: um para cadastrar os dados de uma semana (e suas palestras); outro para cadastrar em massa os estudantes.

**NÃO EXECUTE O cria_dados.sql EM PRODUÇÃO POIS TODOS OS DADOS SERÃO APAGADOS!!!!**

### Atenção
Se o arquivo que contém os dados (estudantes e palestras) estiver codificado com UTF8 então é preciso criar o arquivo **ij.properties** com o seguinte conteúdo:

```
derby.ui.codeset=UTF8
```

O uso do programa **ij** também muda:

```
java -jar ~/apps/derby/lib/derbyrun.jar ij -p ij.properties 
```

Para executar o script SQL:

```
run `cria_dados.sql`;
```


Terminada esta etapa de configuração temos:
* o SGBD Derby no ar
* a base de dados SECCOM_FREQ criada e povoada com dados

Agora é preciso configurar a aplicação para que ela possa ser executada em ambiente de produção.

## Configurando a aplicação
O "programa executável" da aplicação é o arquivo **seccom-freq.war**. Este arquivo contém, na forma compactada (zipada), todos os arquivos que formam a aplicação. É preciso alterar o arquivo **META-INF/context.xml** para os dados de usuário e senha da conexão com o banco de dados sejam iguais aos que foram definidos no arquivo *cria_banco.sql*. Para isso:

```
unzip -d seccom-freq seccom-freq.war
```
Edite o arquivo **seccom-freq/META-INF/context.xml** e substitua o conteúdo dos atributos *username* e *password* para os valores que foram definidos em *cria_banco.sql*. Assim, o Tomcat conseguirá se conectar com o Berby para executar os comandos SQL.

Apague a versão antiga de **seccom-freq.war**

```
rm seccom-freq.war
```
e gere a nova versão (compactando o conteúdo do diretório **seccom-freq**):

```
cd seccom-freq
zip -r ../seccom-freq.war *
```
**Atenção**: tenha certeza que o conteúdo do arquivo **seccom-freq.war** gerado é formado pelos arquivos que estão dentro do diretório **seccom-freq** e os caminhos (paths) não iniciam com *seccom-freq/...".

Coloque o Tomcat no ar executando

```
startup.sh
```

Copie o arquivo **seccom-freq.war** para dentro do diretório **TOMCAT_HOME/webapps**

```
cp seccom-freq.war $TOMCAT_HOME/webapps
```

Se tudo deu certo a aplicação está disponível no endereço **https://host:8443/seccom-freq**  onde host é o nome do computador que hospeda a aplicação.





