package seccom.freq.banco;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.sql.DataSource;
import seccom.freq.modelo.Semana;
import seccom.freq.ws.WSSemana;

/**
 *
 * @author leandro
 */
public class BDUtil {

    public static boolean cadastreSemana(DataSource ds, Semana semana) {
        String sql = "insert into SEMANA values(" + String.valueOf(semana.getAno()) + ",'" + semana.getNome() + "','" + semana.getTema() + "')";
        return executeInsert(ds, sql);
    }

    private static boolean executeInsert(DataSource ds, String sql) {
        boolean cadastrou = true;
        Connection con = null;
        Statement stmt = null;
        try {
            con = ds.getConnection();
            stmt = con.createStatement();
            stmt.executeUpdate(sql);
        } catch (SQLException ex) {
            Logger.getLogger(WSSemana.class.getName()).log(Level.SEVERE, null, ex);
            cadastrou = false;
        } finally {
            try {
                if (stmt != null) {
                    stmt.close();
                }
                if (con != null) {
                    con.close();
                }
            } catch (SQLException ex) {
                Logger.getLogger(BDUtil.class.getName()).log(Level.SEVERE, null, ex);
                cadastrou = false;
            }

        }
        return cadastrou;
    }
}
