package seccom.freq.ws;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
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

/**
 *
 * @author leandro
 */
@WebServlet(name = "WSEstudante", urlPatterns = {"/WSEstudante/cadastrar", "/WSEstudante/encontrarTodos", "/WSEstudante/encontrarPorMatricula"})
public class WSEstudante extends HttpServlet {

    final int T = "/WSEstudante/".length();

    enum Servicos {
        cadastrar,
        encontrarTodos,
        encontrarPorMatricula
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
            case encontrarTodos: {
                resposta = encontreTodosOsEstudantes();
                break;
            }
            case encontrarPorMatricula: {
                resposta = encontrePorMatricula(request);
                break;
            }
        }
        return resposta;
    }

    private JsonObject cadastre(HttpServletRequest request) {
        final String FIM_DE_LINHA = "\\r?\\n|\\r"; // Windows (\r\n), Linux (\n) e Mac (\r ou \n)
        
        String[] csvEstudantes = request.getParameter("estudantes").split(FIM_DE_LINHA);
        List<Estudante> estudantes = new ArrayList<>();
        String[] matricula_nome;
        for (String csvEstudante : csvEstudantes) {
            matricula_nome = csvEstudante.split(",");
            estudantes.add(new Estudante(Integer.parseInt(matricula_nome[0]), matricula_nome[1]));
        }
        List<Estudante> jaCadastrados = BDUtil.cadastreEstudantes(ds, estudantes);
        JsonObject jo = new JsonObject();
        jo.addProperty("Msg", "EstudantesCadastrados");
        jo.addProperty("qtdSolicitada", estudantes.size());
        jo.addProperty("qtdCadastrada", estudantes.size() - jaCadastrados.size());
        if (jaCadastrados.size() > 0) {
            JsonArray ja = new JsonArray();
            for (Estudante e : jaCadastrados)
                ja.add(gson.toJsonTree(e));
            jo.add("naoCadastrados", ja);
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

    private JsonObject encontrePorMatricula(HttpServletRequest request) {
        Estudante e = BDUtil.encontreEstudantePorMatricula(ds, Integer.parseInt(request.getParameter("matricula")));
        System.out.println(e);
        JsonObject jo = new JsonObject();
        if (e != null) {
            jo.addProperty("Msg", "EstudanteEncontrado");
            jo.add("estudante", gson.toJsonTree(e));
        } else {
            jo.addProperty("Msg", "EstudanteNaoEncontrado");
        }
        return jo;
    }
}
