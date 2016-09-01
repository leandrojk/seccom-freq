package seccom.freq.util;

import com.google.gson.JsonObject;
import java.text.SimpleDateFormat;
import seccom.freq.modelo.Palestra;

/**
 *
 * @author leandro
 */
public class UtilGSON {
        private final static SimpleDateFormat dfDia = new SimpleDateFormat("dd/MM/yyyy");
        private final static SimpleDateFormat dfHora = new SimpleDateFormat("H:mm");

    public static JsonObject toJSON(Palestra palestra) {
        String dia = dfDia.format(palestra.getDia());
        String horarioDeInicio = dfHora.format(palestra.getHorarioDeInicio());
        String horarioDeTermino = dfHora.format(palestra.getHorarioDeTermino());
        JsonObject jo = new JsonObject();

        jo.addProperty("id", palestra.getId());
        jo.addProperty("semanaAno", palestra.getSemanaAno());
        jo.addProperty("titulo", palestra.getTitulo());
        jo.addProperty("palestrante", palestra.getPalestrante());
        jo.addProperty("dia", dia);
        jo.addProperty("horarioDeInicio", horarioDeInicio);
        jo.addProperty("horarioDeTermino", horarioDeTermino);
        
        return jo;
    }
}
