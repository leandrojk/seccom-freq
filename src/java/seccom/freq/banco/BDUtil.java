package seccom.freq.banco;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.sql.DataSource;
import seccom.freq.modelo.Palestra;
import seccom.freq.modelo.Semana;
import seccom.freq.ws.WSSemana;

/**
 *
 * @author leandro
 */
public class BDUtil {

    public static boolean cadastreSemana(DataSource ds, Semana semana) {
        String sql = "insert into SEMANA values(?,?,?)";
        boolean inseriu = true;
        Connection con = null;
        PreparedStatement ppstmt = null;
        try {
            con = ds.getConnection();
            ppstmt = con.prepareStatement(sql);
            ppstmt.setInt(1, semana.getAno());
            ppstmt.setString(2, semana.getNome());
            ppstmt.setString(3, semana.getTema());
            ppstmt.execute();
        } catch (SQLException ex) {
            Logger.getLogger(WSSemana.class.getName()).log(Level.SEVERE, null, ex);
            inseriu = false;
        } finally {
            try {
                if (ppstmt != null) {
                    ppstmt.close();
                }
                if (con != null) {
                    con.close();
                }
            } catch (SQLException ex) {
                Logger.getLogger(BDUtil.class.getName()).log(Level.SEVERE, null, ex);
                inseriu = false;
            }

        }
        return inseriu;
    }

    public static Palestra cadastrePalestra(DataSource ds, Palestra) {
        String sql = "insert into PALESTRA values(null,?,?,?,?,?,?)";
        boolean inseriu = true;
        Connection con = null;
        PreparedStatement ppstmt = null;
        try {
            con = ds.getConnection();
            ppstmt = con.prepareStatement(sql);
            ppstmt.setInt(1, semana.getAno());
            ppstmt.setString(2, semana.getNome());
            ppstmt.setString(3, semana.getTema());
            ppstmt.execute();
        } catch (SQLException ex) {
            Logger.getLogger(WSSemana.class.getName()).log(Level.SEVERE, null, ex);
            inseriu = false;
        } finally {
            try {
                if (ppstmt != null) {
                    ppstmt.close();
                }
                if (con != null) {
                    con.close();
                }
            } catch (SQLException ex) {
                Logger.getLogger(BDUtil.class.getName()).log(Level.SEVERE, null, ex);
                inseriu = false;
            }

        }
        return inseriu;
    }

    public static List<Semana> encontreTodasAsSemanas(DataSource ds) {
        String sql = "select * from SEMANA order by ano desc";
        List<Semana> semanas = new ArrayList<>();
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = ds.getConnection();
            stmt = con.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                semanas.add(new Semana(rs.getInt(1), rs.getString(2), rs.getString(3)));                
            }
        } catch (SQLException ex) {
            Logger.getLogger(WSSemana.class.getName()).log(Level.SEVERE, null, ex);
            //TODO tratar erro;
        } finally {
            try {
                if (rs != null)
                    rs.close();
                if (stmt != null) {
                    stmt.close();
                }
                if (con != null) {
                    con.close();
                }
            } catch (SQLException ex) {
                Logger.getLogger(BDUtil.class.getName()).log(Level.SEVERE, null, ex);
                //TODO tratar erro
            }

        }

        return semanas;
    }
    
    
    public static Semana encontreSemanaPorAno(DataSource ds, int ano) {
        String sql = "select * from SEMANA where ano = ?";
        Semana semana = null;
        Connection con = null;
        PreparedStatement ppstmt = null;
        ResultSet rs = null;
        try {
            con = ds.getConnection();
            ppstmt = con.prepareStatement(sql);
            ppstmt.setInt(1, ano);
            rs = ppstmt.executeQuery();
            if (rs.next()) {
                semana = new Semana(rs.getInt(1), rs.getString(2), rs.getString(3));                
            }
        } catch (SQLException ex) {
            Logger.getLogger(WSSemana.class.getName()).log(Level.SEVERE, null, ex);
            //TODO tratar erro;
        } finally {
            try {
                if (rs != null)
                    rs.close();
                if (ppstmt != null) {
                    ppstmt.close();
                }
                if (con != null) {
                    con.close();
                }
            } catch (SQLException ex) {
                Logger.getLogger(BDUtil.class.getName()).log(Level.SEVERE, null, ex);
                //TODO tratar erro
            }

        }

        return semana;
    }

}
