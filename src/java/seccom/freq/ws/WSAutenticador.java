package seccom.freq.ws;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import java.io.IOException;
import java.io.PrintWriter;
import javax.annotation.Resource;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;
import seccom.freq.banco.BDUtil;
import seccom.freq.modelo.Usuario;

/**
 *
 * @author leandro
 *
 * Implementa serviço de autenticaçao.
 */
@WebServlet(name = "WSAutenticador", urlPatterns = {"/WSAutenticador/fazerLogin", "/WSAutenticador/fazerLogout"})
public class WSAutenticador extends HttpServlet {
    final int T = "/WSAutenticador/".length();
    enum Servicos {
        fazerLogin,
        fazerLogout
    }
    Gson gson = new Gson();
    
    @Resource(name = "jdbc/SECCOMDB")
    DataSource ds;
    
    public static JsonObject respostaNaoLogado() {
        JsonObject jo = new JsonObject();
        jo.addProperty("Msg", "UsuarioNaoLogado");
        return jo;
    }

    
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
        Servicos servicoDesejado = Servicos.valueOf(request.getServletPath().substring(T));
        try (PrintWriter out = response.getWriter()) {
            JsonObject resposta = null;
            switch (servicoDesejado) {
                case fazerLogin:
                    resposta = processeLogin(request);
                    break;
                case fazerLogout:
                    resposta = processeLogout(request);
                    break;
            }
            out.print(resposta);

        }
    }

    private JsonObject processeLogin(HttpServletRequest request) {
        
        String login = request.getParameter("login");
        String senha = request.getParameter("senha");
        Usuario u;
        
        u = BDUtil.encontreUsuario(ds, login);
        
        if (u != null && u.getSenha().equals(senha)) {
            request.getSession().setAttribute(ATTR_LOGADO, u);
            JsonObject jo = new JsonObject();
            jo.addProperty("Msg", "LoginAceito");
            u.apagueSenha(); // para evitar que a senha fique disponível no browser
            jo.add("usuario", gson.toJsonTree(u));
            return jo;
        } else {
            HttpSession sessao = request.getSession(false);
            if (sessao != null) {
                sessao.invalidate();
            }
            JsonObject jo = new JsonObject();
            jo.addProperty("Msg", "LoginNaoAceito");
            return jo;
        }
    }

    private JsonObject processeLogout(HttpServletRequest request) {
        HttpSession sessao = request.getSession(false);
        if (sessao != null) {
            sessao.invalidate();
        }
            JsonObject jo = new JsonObject();
            jo.addProperty("Msg", "LogoutConcluido");
            return jo;
    }

    public static boolean estaLogado(HttpServletRequest request) {
        HttpSession sessao = request.getSession(false);
        if (sessao == null) {
            return false;
        } else {
            return  sessao.getAttribute(ATTR_LOGADO) != null;
        }
    }
    
    public static boolean estaLogadoComoAdministrador(HttpServletRequest request) {
        HttpSession sessao = request.getSession(false);
        if (sessao == null) {
            return false;
        } else {
            Usuario usuarioLogado = (Usuario) sessao.getAttribute(ATTR_LOGADO);
            
            return usuarioLogado != null && usuarioLogado.isAdm();
        }
    }
    
    public static JsonObject invalideSessao(HttpServletRequest request) {
        HttpSession sessao = request.getSession(false);
        if (sessao != null) {
            sessao.invalidate();
        }
        return respostaNaoLogado();
    }
}
