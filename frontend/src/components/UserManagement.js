import React, { useState, useEffect } from 'react';
import './UserManagement.css';

function UserManagement({ showToast, confirmCustom }) {
    const [users, setUsers] = useState([]);
    const [showAddModal, setShowAddModal] = useState(false);
    const [newUser, setNewUser] = useState({
        username: '',
        password: '',
        email: '',
        role: 'servicios_escolares',
        carrera: '',
        profesor_id: ''
    });
    const [carreras, setCarreras] = useState([]);
    const [profesores, setProfesores] = useState([]);
    const [loading, setLoading] = useState(false);

    const API_URL = `http://${window.location.hostname}:9000/api`;

    useEffect(() => {
        fetchUsers();
        fetchCarrerasYProfesores();
    }, []);

    const fetchCarrerasYProfesores = async () => {
        try {
            const [cRes, pRes] = await Promise.all([
                fetch(`${API_URL}/carreras`),
                fetch(`${API_URL}/profesores`)
            ]);
            if (cRes.ok) setCarreras(await cRes.json());
            if (pRes.ok) setProfesores(await pRes.json());
        } catch (error) {
            console.error('Error fetching support data:', error);
        }
    };

    const fetchUsers = async () => {
        try {
            const response = await fetch(`${API_URL}/auth/users`);
            if (response.ok) {
                const data = await response.json();
                setUsers(data);
            }
        } catch (error) {
            console.error('Error fetching users:', error);
        }
    };

    const handleAddUser = async (e) => {
        e.preventDefault();
        setLoading(true);

        try {
            const response = await fetch(`${API_URL}/auth/register`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(newUser),
            });

            if (response.ok) {
                setShowAddModal(false);
                setNewUser({
                    username: '',
                    password: '',
                    email: '',
                    role: 'servicios_escolares',
                    carrera: '',
                    profesor_id: ''
                });
                fetchUsers(); // Refrescar la lista
                showToast('Usuario creado exitosamente', 'success');
            } else {
                const error = await response.json();
                showToast(`Error: ${error.detail}`, 'error');
            }
        } catch (error) {
            console.error('Error creating user:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleDeleteUser = (userId) => {
        confirmCustom({
            title: "Eliminar Usuario",
            message: "¿Está seguro de eliminar este usuario? Esta acción no se puede deshacer.",
            type: 'danger',
            icon: 'error',
            onConfirm: () => ejecutarBorradoUsuario(userId)
        });
    };

    const ejecutarBorradoUsuario = async (userId) => {
        try {
            const response = await fetch(`${API_URL}/auth/users/${userId}`, {
                method: 'DELETE',
            });

            if (response.ok) {
                fetchUsers(); // Refrescar la lista
                showToast('Usuario eliminado exitosamente', 'success');
            } else {
                showToast('Error al eliminar usuario', 'error');
            }
        } catch (error) {
            console.error('Error deleting user:', error);
            showToast('Error al eliminar usuario', 'error');
        }
    };

    return (
        <div className="user-management">
            <div className="user-management-header">
                <h2>Gestión de Usuarios</h2>
                <button className="add-user-btn" onClick={() => setShowAddModal(true)}>
                    + Nuevo Usuario
                </button>
            </div>

            <div className="users-table-container">
                <table className="users-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Usuario</th>
                            <th>Email</th>
                            <th>Rol</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        {users.map(user => (
                            <tr key={user.id}>
                                <td>{user.id}</td>
                                <td>{user.username}</td>
                                <td>{user.email || 'N/A'}</td>
                                <td>
                                    <span className={`role-badge role-${user.role}`}>
                                        {user.role === 'administrador' ? 'Administrador' :
                                            user.role === 'servicios_escolares' ? 'Servicios Escolares' :
                                                user.role === 'jefe_carrera' ? 'Jefe de Carrera' : user.role}
                                    </span>
                                </td>
                                <td>
                                    <span className={`status-badge ${user.is_active ? 'active' : 'inactive'}`}>
                                        {user.is_active ? 'Activo' : 'Inactivo'}
                                    </span>
                                </td>
                                <td>
                                    <button
                                        className="delete-btn"
                                        onClick={() => handleDeleteUser(user.id)}
                                    >
                                        Eliminar
                                    </button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>

            {showAddModal && (
                <div className="modal-overlay" onClick={() => setShowAddModal(false)}>
                    <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                        <h3>Nuevo Usuario</h3>
                        <form onSubmit={handleAddUser}>
                            <div className="form-group">
                                <label>Usuario</label>
                                <input
                                    type="text"
                                    value={newUser.username}
                                    onChange={(e) => setNewUser({ ...newUser, username: e.target.value })}
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label>Contraseña</label>
                                <input
                                    type="password"
                                    value={newUser.password}
                                    onChange={(e) => setNewUser({ ...newUser, password: e.target.value })}
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label>Email (opcional)</label>
                                <input
                                    type="email"
                                    value={newUser.email}
                                    onChange={(e) => setNewUser({ ...newUser, email: e.target.value })}
                                />
                            </div>
                            <div className="form-group">
                                <label>Rol</label>
                                <select
                                    value={newUser.role}
                                    onChange={(e) => setNewUser({ ...newUser, role: e.target.value })}
                                >
                                    <option value="servicios_escolares">Servicios Escolares</option>
                                    <option value="administrador">Administrador</option>
                                    <option value="jefe_carrera">Jefe de Carrera</option>
                                </select>
                            </div>
                            {newUser.role === 'jefe_carrera' && (
                                <>
                                    <div className="form-group">
                                        <label>Carrera Asignada</label>
                                        <select
                                            value={newUser.carrera}
                                            onChange={(e) => setNewUser({ ...newUser, carrera: e.target.value })}
                                            required
                                        >
                                            <option value="">Seleccionar Carrera</option>
                                            {/* Usar un Set para nombres únicos de carreras si es necesario, 
                                                pero aquí solemos usar la clave de carrera de la API */}
                                            {/* Como la DB tiene carreras con nombres, intentaremos obtener las claves 
                                                o usar el nombre si el sistema lo requiere. 
                                                El backend espera la CLAVE (ej: 06B) */}
                                            {/* Si la API /carreras devuelve objetos con 'codigo' o 'id' que mapee a clave: */}
                                            {carreras.map(c => (
                                                <option key={c.id} value={c.codigo || c.nombre}>{c.nombre}</option>
                                            ))}
                                        </select>
                                    </div>
                                    <div className="form-group">
                                        <label>Profesor Correspondiente</label>
                                        <select
                                            value={newUser.profesor_id}
                                            onChange={(e) => setNewUser({ ...newUser, profesor_id: e.target.value })}
                                            required
                                        >
                                            <option value="">Seleccionar Profesor</option>
                                            {profesores.map(p => (
                                                <option key={p.id} value={p.id}>{p.nombre}</option>
                                            ))}
                                        </select>
                                    </div>
                                </>
                            )}
                            <div className="modal-actions">
                                <button type="button" onClick={() => setShowAddModal(false)}>
                                    Cancelar
                                </button>
                                <button type="submit" disabled={loading}>
                                    {loading ? 'Creando...' : 'Crear Usuario'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}

export default UserManagement;
