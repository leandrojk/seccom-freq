package seccom.freq.modelo;

/**
 *
 * @author leandro
 */
public class Usuario {
    String login;
    String senha;
    String nome;
    boolean adm;

    public Usuario(String login, String senha, String nome, boolean adm) {
        this.login = login;
        this.senha = senha;
        this.nome = nome;
        this.adm = adm;
    }

    public String getLogin() {
        return login;
    }

    public String getSenha() {
        return senha;
    }

    public String getNome() {
        return nome;
    }


    public boolean isAdm() {
        return adm;
    }
    
    
}
