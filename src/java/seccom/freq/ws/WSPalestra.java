package seccom.freq.ws;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.sql.Time;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.annotation.Resource;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;
import seccom.freq.banco.BDUtil;
import seccom.freq.modelo.Palestra;
import seccom.freq.util.UtilGSON;

/**
 *
 * @author leandro
 */
@WebServlet(name = "WSPalestra", urlPatterns = {"/WSPalestra/cadastrar", "/WSPalestra/encontrarPorAno"})
public class WSPalestra extends HttpServlet {

    final int T = "/WSPalestra/".length();

    enum Servicos {
        cadastrar,
        encontrarTodas,
        encontrarPorAno
    }

    @Resource(name = "jdbc/SECCOMDB")
    DataSource ds;
    Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print(processePost(request));
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print(processeGet(request));
        }
    }

    private JsonObject processePost(HttpServletRequest request) {
        if (!WSAutenticador.estaLogado(request)) {
            return WSAutenticador.respostaNaoLogado();
        }
        JsonObject resposta = null;
        WSPalestra.Servicos servicoDesejado = WSPalestra.Servicos.valueOf(request.getServletPath().substring(T));

        switch (servicoDesejado) {
            case cadastrar: 
                resposta = cadastre(request);
                break;
        }

        return resposta;
    }

        private JsonObject processeGet(HttpServletRequest request) {
        if (!WSAutenticador.estaLogado(request)) {
            return WSAutenticador.respostaNaoLogado();
        }
        JsonObject resposta = null;
        WSPalestra.Servicos servicoDesejado = WSPalestra.Servicos.valueOf(request.getServletPath().substring(T));

        switch (servicoDesejado) {
            case encontrarPorAno :
                resposta = encontrePorAno(request);
                break;
        }

        return resposta;
    }

    private JsonObject cadastre(HttpServletRequest request) {
        int ano = Integer.parseInt(request.getParameter("ano"));
        String titulo = request.getParameter("titulo");
        String palestrante = request.getParameter("palestrante");
        String sDia = request.getParameter("dia");
        String sHorarioDeInicio = request.getParameter("horariodeinicio");
        String sHorarioDeTermino = request.getParameter("horariodetermino");
                
        SimpleDateFormat dfDia = new SimpleDateFormat("dd/MM/yyyy");
        SimpleDateFormat dfHora = new SimpleDateFormat("H:mm");
        JsonObject jo = new JsonObject();

        try {
            java.util.Date dia = dfDia.parse(sDia);
            java.util.Date hi = dfHora.parse(sHorarioDeInicio);
            java.util.Date ht = dfHora.parse(sHorarioDeTermino);
            Palestra palestra = new Palestra(0, ano, titulo, palestrante, new Date(dia.getTime()), new Time(hi.getTime()), new Time(ht.getTime()));
            if (BDUtil.cadastrePalestra(ds, palestra)) {
                jo.addProperty("Msg", "PalestraFoiCadastrada");
            } else {
                jo.addProperty("Msg", "PalestraNaoFoiCadastrada");
            }
        } catch (ParseException ex) {
            Logger.getLogger(WSPalestra.class.getName()).log(Level.SEVERE, null, ex);
        }

        return jo;
    }

    private JsonObject encontrePorAno(HttpServletRequest request) {
        int ano = Integer.parseInt(request.getParameter("ano"));
        List<Palestra> palestras = BDUtil.encontrePalestrasPorAno(ds,ano);
        JsonObject jo = new JsonObject();
        JsonArray ja = new JsonArray();
                
        jo.addProperty("Msg", "PalestrasEncontradas");
        for (Palestra p : palestras)
            ja.add(UtilGSON.toJSON(p));
        jo.add("palestras", ja);
        return jo;
    }
}
