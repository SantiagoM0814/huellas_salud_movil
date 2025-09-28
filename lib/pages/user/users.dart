import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/users_services.dart';
import '../../widgets/appbar.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final UserService _userService = UserService();
  final List<User> _users = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;
 
  int _currentFilter = 0;
  String _searchQuery = '';

  final List<String> _roles = ['Administrador', 'Veterinario', 'Usuario'];
  final List<String> _statuses = ['Activo', 'Inactivo'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newUsers = await _userService.fetchUsers(
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        if (newUsers.isEmpty) {
          _hasMore = false;
        } else {
          _users.addAll(newUsers);
          _offset += _limit;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar(e.toString());
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _changeUserRole(int index, String newRole) {
    setState(() {
      _users[index].role = newRole;
    });
  }

  void _changeUserStatus(int index, String newStatus) {
    setState(() {
      _users[index].status = newStatus;
    });
  }

  List<User> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }
    return _users.where((user) =>
      user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      user.role.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      user.status.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Usuarios', showBackButton: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar usuarios...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
         
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilterButton(
                text: 'USUARIOS',
                isActive: _currentFilter == 0,
                onTap: () => setState(() => _currentFilter = 0),
              ),
              FilterButton(
                text: 'ESTADO',
                isActive: _currentFilter == 1,
                onTap: () => setState(() => _currentFilter = 1),
              ),
              FilterButton(
                text: 'ROL',
                isActive: _currentFilter == 2,
                onTap: () => setState(() => _currentFilter = 2),
              ),
            ],
          ),
         
          const SizedBox(height: 16),
         
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Usuarios',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Estado',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Rol',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
         
          const Divider(thickness: 1.5),
         
          Expanded(
            child: _filteredUsers.isEmpty && !_isLoading
                ? const Center(child: Text('No hay usuarios disponibles'))
                : ListView.builder(
                    itemCount: _filteredUsers.length + (_isLoading && _hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _filteredUsers.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                     
                      final user = _filteredUsers[index];
                      return UserListItem(
                        user: user,
                        onRoleChanged: (newRole) => _changeUserRole(_users.indexOf(user), newRole),
                        onStatusChanged: (newStatus) => _changeUserStatus(_users.indexOf(user), newStatus),
                        roles: _roles,
                        statuses: _statuses,
                        showRoleOptions: _currentFilter == 2,
                        showStatusOptions: _currentFilter == 1,
                      );
                    },
                  ),
          ),
         
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 3; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == 1 ? Colors.purple : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Text(
                        i.toString(),
                        style: TextStyle(
                          color: i == 1 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                const Text('...'),
                const SizedBox(width: 8),
                for (int i = 67; i <= 68; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Text(i.toString()),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const FilterButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.purple : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class UserListItem extends StatelessWidget {
  final User user;
  final Function(String) onRoleChanged;
  final Function(String) onStatusChanged;
  final List<String> roles;
  final List<String> statuses;
  final bool showRoleOptions;
  final bool showStatusOptions;

  const UserListItem({
    super.key,
    required this.user,
    required this.onRoleChanged,
    required this.onStatusChanged,
    required this.roles,
    required this.statuses,
    required this.showRoleOptions,
    required this.showStatusOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.role,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: showStatusOptions
                    ? DropdownButton<String>(
                        value: user.status,
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            onStatusChanged(newStatus);
                          }
                        },
                        items: statuses.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Center(child: Text(status)),
                          );
                        }).toList(),
                        underline: Container(),
                        isExpanded: true,
                      )
                    : Text(
                        user.status,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: user.status == 'Activo'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              Expanded(
                child: showRoleOptions
                    ? DropdownButton<String>(
                        value: user.role,
                        onChanged: (newRole) {
                          if (newRole != null) {
                            onRoleChanged(newRole);
                          }
                        },
                        items: roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Center(child: Text(role)),
                          );
                        }).toList(),
                        underline: Container(),
                        isExpanded: true,
                      )
                    : Text(
                        user.role,
                        textAlign: TextAlign.center,
                      ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}