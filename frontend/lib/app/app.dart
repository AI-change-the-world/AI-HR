import 'package:flutter/material.dart';
import 'package:he/he.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SimpleLayout(
        items: [
          SidebarItem(
            icon: const Icon(Icons.dataset, color: Colors.blueAccent),
            iconInactive: const Icon(Icons.dataset),
            index: 0,
            title: "简历管理",
          ),
          SidebarItem(
            icon: const Icon(Icons.work, color: Colors.blueAccent),
            iconInactive: const Icon(Icons.work),
            index: 1,
            title: "绩效管理",
          ),
          SidebarItem(
            icon: const Icon(Icons.train, color: Colors.blueAccent),
            iconInactive: const Icon(Icons.train),
            index: 2,
            title: "员工培训",
          ),
          SidebarItem(
            icon: const Icon(Icons.settings, color: Colors.blueAccent),
            iconInactive: const Icon(Icons.settings),
            index: 3,
            title: "设置中心",
          ),
        ],
        children: [Container(), Container(), Container(), Container()],
      ),
    );
  }
}
