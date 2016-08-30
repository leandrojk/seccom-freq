package seccom.freq.ws;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.annotation.Resource;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;
import seccom.freq.banco.BDUtil;
import seccom.freq.modelo.Semana;

/**
 *
 * @author leandro
 */
@WebServlet(name = "WSSemana", urlPatterns = {"/WSSemana/cadastrar", "/WSSemana/encontrarTodas", "/WSSemana/encontrarPorAno"})
public class WSSemana extends HttpServlet {

    final int T = "/WSSemana/".length();

    enum Servicos {
        cadastrar,
        encontrarTodas,
        encontrarPorAno
    }

    @Resource(name = "jdbc/SECCOMDB")
    DataSource ds;
    Gson gson = new Gson();

    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
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
        Servicos servicoDesejado = Servicos.valueOf(request.getServletPath().substring(T));

        switch (servicoDesejado) {
            case cadastrar: {
                resposta = cadastre(request);
                break;
            }
        }

        return resposta;
    }

    private JsonObject processeGet(HttpServletRequest request) {
        if (!WSAutenticador.estaLogado(request)) {
            return WSAutenticador.respostaNaoLogado();
        }

        JsonObject resposta = null;
        Servicos servicoDesejado = Servicos.valueOf(request.getServletPath().substring(T));

        switch (servicoDesejado) {
            case encontrarTodas: {
                resposta = encontreTodasAsSemanas();
                break;
            }
            case encontrarPorAno: {
                resposta = encontrePorAno(request);
                break;
            }
        }
        return resposta;
    }

    private JsonObject cadastre(HttpServletRequest request) {
        int ano = Integer.parseInt(request.getParameter("ano"));
        String nome = request.getParameter("nome");
        String tema = request.getParameter("tema");
        JsonObject jo = new JsonObject();
        if (BDUtil.cadastreSemana(ds, new Semana(ano, nome, tema))) {
            jo.addProperty("Msg", "SemanaFoiCadastrada");
        } else {
            jo.addProperty("Msg", "SemanaNaoFoiCadastrada");
        }
        return jo;
    }

    private JsonObject encontreTodasAsSemanas() {
        List<Semana> semanas = BDUtil.encontreTodasAsSemanas(ds);
        JsonObject jo = new JsonObject();
        JsonArray ja = new JsonArray();

        for (Semana s : semanas) {
            ja.add(gson.toJsonTree(s));
        }

        jo.addProperty("Msg", "SemanasEncontradas");
        jo.add("semanas", ja);
        
        return jo;
    }

    private JsonObject encontrePorAno(HttpServletRequest request) {
        Semana s = BDUtil.encontreSemanaPorAno(ds, Integer.parseInt(request.getParameter("ano")));
        System.out.println(s);
        JsonObject jo = new JsonObject();
        if (s != null) {
            jo.addProperty("Msg", "SemanaEncontrada");
            jo.add("semana", gson.toJsonTree(s));
        } else {
            jo.addProperty("Msg", "SemanaNaoEncontrada");
        }
        return jo;
    }
}
