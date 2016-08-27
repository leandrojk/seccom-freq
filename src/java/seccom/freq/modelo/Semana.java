package seccom.freq.modelo;

/**
 *
 * @author leandro
 */
public class Semana {
    int ano;
    String nome;
    String tema;

    public Semana(int ano, String nome, String tema) {
        this.ano = ano;
        this.nome = nome;
        this.tema = tema;
    }

    public Semana(String dados) {
        String[] campos = dados.split("/");
        ano = Integer.parseInt(campos[0]);
        nome = campos[1];
        tema = campos[2];
    }
    
    public int getAno() {
        return ano;
    }

    public String getNome() {
        return nome;
    }

    public String getTema() {
        return tema;
    }
    
    
}
