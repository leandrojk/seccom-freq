package seccom.freq.modelo;

/**
 *
 * @author leandro
 */
public class Estudante {
    int matricula;
    String nome;

    public Estudante(int matricula, String nome) {
        this.matricula = matricula;
        this.nome = nome;
    }

    public int getMatricula() {
        return matricula;
    }

    public String getNome() {
        return nome;
    }        
}
