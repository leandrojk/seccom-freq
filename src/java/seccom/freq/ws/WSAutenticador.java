package seccom.freq.ws;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author leandro
 *
 * Implementa serviço de autenticaçao.
 */
@WebServlet(name = "Autenticador", urlPatterns = {"/Autenticador/login", "/Autenticador/logout"})
public class WSAutenticador extends HttpServlet {

    // senha de autenticação do usuário
    final private String CODIGO_DE_ACESSO = "c";
    
    // attributo da session que indica se usuário está logado ou não
    final private static String ATTR_LOGADO = "logado";

    /**
     * Handles the HTTP <code>POST</code> method.
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
            String resposta = "";
            switch (request.getServletPath()) {
                case "/Autenticador/login":
                    resposta = processeLogin(request);
                    break;
                case "/Autenticador/logout":
                    resposta = processeLogout(request);
                    break;
            }
            out.print(resposta);

        }
    }

    private String processeLogin(HttpServletRequest request) {
        String codigo = request.getParameter("codigo");

        if (codigo.equals(CODIGO_DE_ACESSO)) {
            request.getSession().setAttribute(ATTR_LOGADO, true);
            return "true";  // JSON true
        } else {
            HttpSession sessao = request.getSession(false);
            if (sessao != null) {
                sessao.invalidate();
            }
            return "false"; // JSON false
        }
    }

    private String processeLogout(HttpServletRequest request) {
        HttpSession sessao = request.getSession(false);
        if (sessao != null) {
            sessao.invalidate();
        }
        return "true"; // JSON true
    }

    public static boolean estaLogado(HttpServletRequest request) {
        HttpSession sessao = request.getSession(false);
        if (sessao == null) {
            return false;
        } else {
            return sessao.getAttribute(ATTR_LOGADO) != null;
        }
    }
}
