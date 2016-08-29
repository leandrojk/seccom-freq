package seccom.freq.ws;

import com.google.gson.JsonObject;
import java.io.IOException;
import java.io.PrintWriter;
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
@WebServlet(name = "WSSemana", urlPatterns = {"/WSSemana/cadastrar/*"})
public class WSSemana extends HttpServlet {

    @Resource(name = "jdbc/SECCOMDB")
    DataSource ds;

    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print(processe(request));
        }

    }

    private JsonObject processe(HttpServletRequest request) {
        if (!WSAutenticador.estaLogado(request)) {
            return WSAutenticador.respostaNaoLogado();
        }

        String path = request.getServletPath();

        String servico = "/WSSemana/cadastrar";
        JsonObject resposta = null;
        if (path.startsWith(servico)) {
            resposta = cadastre(request.getPathInfo().substring(1));
        }
        return resposta;
    }

    private JsonObject cadastre(String dadosDaSemana) {
        JsonObject jo = new JsonObject();
        jo.addProperty("msg", "MsgCadastrou");
        if (BDUtil.cadastreSemana(ds, new Semana(dadosDaSemana))) {
            jo.addProperty("resultado", Boolean.TRUE);
        } else {
            jo.addProperty("resultado", Boolean.FALSE);
        }
        return jo;
    }

}
