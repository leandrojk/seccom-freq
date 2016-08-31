package seccom.freq.modelo;
import java.sql.Date;
import java.sql.Time;

/**
 *
 * @author leandro
 */
public class Palestra {
    int id;
    int semanaAno;
    String titulo;
    String palestrante;
    Date dia;
    Time horarioDeInicio;
    Time horarioDeTermino;
    

    public Palestra(int id, int semanaAno, String titulo, String palestrante, Date dia, Time horarioDeInicio, Time horarioDeTermino) {
        this.id = id;
        this.semanaAno = semanaAno;
        this.titulo = titulo;
        this.palestrante = palestrante;
        this.dia = dia;
        this.horarioDeInicio = horarioDeInicio;
        this.horarioDeTermino = horarioDeTermino;
    }

    public void setId(int id) {
        this.id = id;
    }
    
    public int getId() {
        return id;
    }

    public int getSemanaAno() {
        return semanaAno;
    }

    public String getTitulo() {
        return titulo;
    }

    public String getPalestrante() {
        return palestrante;
    }

    public Date getDia() {
        return dia;
    }

    public Time getHorarioDeInicio() {
        return horarioDeInicio;
    }

    public Time getHorarioDeTermino() {
        return horarioDeTermino;
    }
    
    
}
