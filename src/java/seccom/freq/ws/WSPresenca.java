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
import seccom.freq.modelo.Estudante;
import seccom.freq.modelo.Presenca;

/**
 *
 * @author leandro
 */
@WebServlet(name = "WSPresenca", urlPatterns = {"/WSPresenca/cadastrar", "/WSPresenca/encontrarPorPalestra", "/WSPresenca/encontrarEstudantesPorPalestra"})
public class WSPresenca extends HttpServlet {

    final int T = "/WSPresenca/".length();

    enum Servicos {
        cadastrar,
        encontrarPorPalestra,
        encontrarEstudantesPorPalestra
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
            case encontrarPorPalestra: {
                resposta = encontrePorPalestra(request);
                break;
            }
            case encontrarEstudantesPorPalestra: {
                resposta = encontreEstudantesPorPalestra(request);
                break;
            }
        }
        return resposta;
    }

    private JsonObject cadastre(HttpServletRequest request) {
        int matricula = Integer.parseInt(request.getParameter("matricula"));
        int palestra = Integer.parseInt(request.getParameter("palestra"));
        Presenca presenca = new Presenca(matricula, palestra);

        boolean cadastrou = BDUtil.cadastrePresenca(ds, presenca);
        JsonObject jo = new JsonObject();
        if (cadastrou) {
            jo.addProperty("Msg", "PresencaCadastrada");
        } else {
            jo.addProperty("Msg", "PresencaJaCadastrada");
        }
        return jo;
    }

    private JsonObject encontreTodosOsEstudantes() {
        List<Estudante> estudantes = BDUtil.encontreTodosOsEstudantes(ds);
        JsonObject jo = new JsonObject();
        JsonArray ja = new JsonArray();

        for (Estudante e : estudantes) {
            ja.add(gson.toJsonTree(e));
        }

        jo.addProperty("Msg", "EstudantesEncontrados");
        jo.add("estudantes", ja);

        return jo;
    }

    // retorna o número de matrícula dos alunos presentes em uma palestra
    private JsonObject encontrePorPalestra(HttpServletRequest request) {
        List<Integer> matriculas = BDUtil.encontreMatriculasPresentesPorPalestra(ds, Integer.parseInt(request.getParameter("palestra")));
        JsonObject jo = new JsonObject();
        jo.addProperty("Msg", "MatriculasEncontradas");
        jo.add("matriculas", gson.toJsonTree(matriculas));
        return jo;
    }

    // retorna os estudantes presentes em uma palestra
    private JsonObject encontreEstudantesPorPalestra(HttpServletRequest request) {
        List<Estudante> estudantes = BDUtil.encontreEstudantesPorPalestra(ds, Integer.parseInt(request.getParameter("palestra")));
        JsonObject jo = new JsonObject();
        JsonArray ja = new JsonArray();

        for (Estudante e : estudantes) {
            ja.add(gson.toJsonTree(e));
        }

        jo.addProperty("Msg", "EstudantesEncontrados");
        jo.add("estudantes", ja);
        return jo;
    }
}
