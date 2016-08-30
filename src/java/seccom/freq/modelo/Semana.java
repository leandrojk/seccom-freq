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
