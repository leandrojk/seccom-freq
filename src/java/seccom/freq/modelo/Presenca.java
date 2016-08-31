package seccom.freq.modelo;

/**
 *
 * @author leandro
 */
public class Presenca {
    int estudanteMatricula;  // matrícula do estudante
    int palestraId;   // id da palestra

    public Presenca(int estudanteMatricula, int palestraId) {
        this.estudanteMatricula = estudanteMatricula;
        this.palestraId = palestraId;
    }

    public int getEstudanteMatricula() {
        return estudanteMatricula;
    }

    public int getPalestraId() {
        return palestraId;
    }    
}
