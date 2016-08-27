package seccom.freq.ws;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.annotation.Resource;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

/**
 *
 * @author leandro
 */
@WebServlet(name = "WSSemana", urlPatterns = {"/WSSemana/cadastrar/*"})
public class WSSemana extends HttpServlet {

    @Resource(name="jdbc/SECCOMDB")
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

    private String processe(HttpServletRequest request) {
        if (!WSAutenticador.estaLogado(request))
            return WSAutenticador.respostaNaoLogado();
        
        String path = request.getServletPath();

        String servico = "/WSSemana/cadastrar";
        String resposta = "erro";
        if (path.startsWith(servico)) {
            resposta = cadastre(request.getPathInfo().substring(1));
        }
        return resposta;
    }

    private String cadastre(String dadosDaSemana) {
        String[] dados = dadosDaSemana.split("/");
        String erro = valideCadastrar(dados);

        if (erro != null) {
            return erro;
        }

        return dadosDaSemana;

    }

    private String valideCadastrar(String[] dados) {
        if (dados.length != 3) {
            return "erro na solicitaçao: deve ser ano/nome/tema";
        }
        try {
            int ano = Integer.parseInt(dados[0]);
            if (ano < 2000) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            return "erro na solicitaçao: o primeiro dado de ser um numero maior ou igual a 2000";
        }
        try {
            Connection con = ds.getConnection();
            Statement stmt = con.createStatement();
            String sql = "insert into SEMANA values(" + dados[0] + ",'" + dados[1] + "','" + dados[2] + "')";
            stmt.executeUpdate(sql);
            stmt.close();
            con.close();
        } catch (SQLException ex) {
            Logger.getLogger(WSSemana.class.getName()).log(Level.SEVERE, null, ex);
        }
        return "{\"ok\":,\"true\"}";

    }
}
