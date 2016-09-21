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
import seccom.freq.modelo.Estudante;
import seccom.freq.modelo.Palestra;
import seccom.freq.modelo.Presenca;
import seccom.freq.modelo.Semana;
import seccom.freq.modelo.Usuario;
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

    public static boolean cadastrePalestra(DataSource ds, Palestra palestra) {
        String sql = "insert into PALESTRA (SEMANA_ANO, TITULO, PALESTRANTE, DIA, HORARIODEINICIO, HORARIODETERMINO)values(?,?,?,?,?,?)";
        boolean inseriu = true;
        Connection con = null;
        PreparedStatement ppstmt = null;
        try {
            con = ds.getConnection();
            ppstmt = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ppstmt.setInt(1, palestra.getSemanaAno());
            ppstmt.setString(2, palestra.getTitulo());
            ppstmt.setString(3, palestra.getPalestrante());
            ppstmt.setDate(4, palestra.getDia());
            ppstmt.setTime(5, palestra.getHorarioDeInicio());
            ppstmt.setTime(6, palestra.getHorarioDeTermino());

            ppstmt.execute();
            ResultSet rs = ppstmt.getGeneratedKeys();
            rs.next();
            palestra.setId(rs.getInt(1));
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
                if (rs != null) {
                    rs.close();
                }
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
                if (rs != null) {
                    rs.close();
                }
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

    public static List<Palestra> encontrePalestrasPorAno(DataSource ds, int ano) {
        String sql = "select * from PALESTRA where semana_ano = ? order by dia, horariodeinicio";
        List<Palestra> palestras = new ArrayList<>();
        Connection con = null;
        PreparedStatement ppstmt = null;
        ResultSet rs = null;
        try {
            con = ds.getConnection();
            ppstmt = con.prepareStatement(sql);
            ppstmt.setInt(1, ano);
            rs = ppstmt.executeQuery();
            while (rs.next()) {
                palestras.add(new Palestra(rs.getInt("ID"), rs.getInt("SEMANA_ANO"), rs.getString("TITULO"), rs.getString("PALESTRANTE"), rs.getDate("DIA"), rs.getTime("HORARIODEINICIO"), rs.getTime("HORARIODETERMINO")));
            }
        } catch (SQLException ex) {
            Logger.getLogger(WSSemana.class.getName()).log(Level.SEVERE, null, ex);
            //TODO tratar erro;
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
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

        return palestras;
    }

    public static List<Estudante> cadastreEstudantes(DataSource ds, List<Estudante> estudantes) {
        String sql = "insert into ESTUDANTE values(?,?)";
        List<Estudante> estudantesJaCadastrados = new ArrayList<>();
        Connection con = null;
        PreparedStatement ppstmt = null;
        try {
            con = ds.getConnection();
            ppstmt = con.prepareStatement(sql);
            for (Estudante e : estudantes) {
                ppstmt.setInt(1, e.getMatricula());
                ppstmt.setString(2, e.getNome());
                try {
                    ppstmt.execute();
                } catch (SQLException ex) {
                    estudantesJaCadastrados.add(e);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(WSSemana.class.getName()).log(Level.SEVERE, null, ex);

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

            }

        }
        return estudantesJaCadastrados;
    }

    public static List<Estudante> encontreTodosOsEstudantes(DataSource ds) {
        String sql = "select * from ESTUDANTE order by nome";
        List<Estudante> estudantes = new ArrayList<>();
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = ds.getConnection();
            stmt = con.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                estudantes.add(new Estudante(rs.getInt("MATRICULA"), rs.getString("NOME")));
            }
        } catch (SQLException ex) {
            Logger.getLogger(WSSemana.class.getName()).log(Level.SEVERE, null, ex);
            //TODO tratar erro;
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
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

        return estudantes;
    }

    public static Estudante encontreEstudantePorMatricula(DataSource ds, int matricula) {
        String sql = "select * from ESTUDANTE where matricula = ?";
        Estudante estudante = null;
        Connection con = null;
        PreparedStatement ppstmt = null;
        ResultSet rs = null;
        try {
            con = ds.getConnection();
            ppstmt = con.prepareStatement(sql);
            ppstmt.setInt(1, matricula);
            rs = ppstmt.executeQuery();
            if (rs.next()) {
                estudante = new Estudante(rs.getInt("MATRICULA"), rs.getString("NOME"));
            }
        } catch (SQLException ex) {
            Logger.getLogger(WSSemana.class.getName()).log(Level.SEVERE, null, ex);
            //TODO tratar erro;
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
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

        return estudante;
    }

    public static List<Estudante> encontreEstudantesPorPalestra(DataSource ds, int idPalestra) {
        String sql = "select ESTUDANTE.* from PRESENCA, ESTUDANTE where PRESENCA.palestra_id = ? and PRESENCA.estudante_matricula = ESTUDANTE.matricula order by ESTUDANTE.nome";
        List<Estudante> estudantes = new ArrayList<>();
        Connection con = null;
        PreparedStatement ppstmt = null;
        ResultSet rs = null;
        try {
            con = ds.getConnection();
            ppstmt = con.prepareStatement(sql);
            ppstmt.setInt(1, idPalestra);
            rs = ppstmt.executeQuery();
            while (rs.next()) {
                estudantes.add(new Estudante(rs.getInt("MATRICULA"), rs.getString("NOME")));
            }
        } catch (SQLException ex) {
            Logger.getLogger(WSSemana.class.getName()).log(Level.SEVERE, null, ex);
            //TODO tratar erro;
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
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

        return estudantes;
    }

    
    public static boolean cadastrePresenca(DataSource ds, Presenca presenca) {
        String sql = "insert into PRESENCA (ESTUDANTE_MATRICULA, PALESTRA_ID) values (?,?)";
        boolean inseriu = true;
        Connection con = null;
        PreparedStatement ppstmt = null;
        try {
            con = ds.getConnection();
            ppstmt = con.prepareStatement(sql);
            ppstmt.setInt(1, presenca.getEstudanteMatricula());
            ppstmt.setInt(2, presenca.getPalestraId());

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

    public static List<Integer> encontreMatriculasPresentesPorPalestra(DataSource ds, int idPalestra) {
        String sql = "select ESTUDANTE_MATRICULA from PRESENCA where PALESTRA_ID  = ? order by ESTUDANTE_MATRICULA";
        List<Integer> matriculas = new ArrayList<>();
        Connection con = null;
        PreparedStatement ppstmt = null;
        ResultSet rs = null;
        try {
            con = ds.getConnection();
            ppstmt = con.prepareStatement(sql);
            ppstmt.setInt(1, idPalestra);
            rs = ppstmt.executeQuery();
            while (rs.next()) {
                matriculas.add(rs.getInt("ESTUDANTE_MATRICULA"));
            }
        } catch (SQLException ex) {
            Logger.getLogger(WSSemana.class.getName()).log(Level.SEVERE, null, ex);
            //TODO tratar erro;
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
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

        return matriculas;
    }

    
    public static Usuario encontreUsuario(DataSource ds, String login) {
        String sql = "select * from USUARIO where login = ?";
        Usuario usuario = null;
        Connection con = null;
        PreparedStatement ppstmt = null;
        ResultSet rs = null;
        try {
            con = ds.getConnection();
            ppstmt = con.prepareStatement(sql);
            ppstmt.setString(1, login);
            rs = ppstmt.executeQuery();
            if (rs.next()) {
                usuario = new Usuario(login, rs.getString("SENHA"), rs.getString("NOME"), rs.getBoolean("ADM"));
            }
        } catch (SQLException ex) {
            Logger.getLogger(BDUtil.class.getName()).log(Level.SEVERE, null, ex);
            //TODO tratar erro;
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
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

        return usuario;
    }

}
