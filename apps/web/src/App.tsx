import { useEffect, useState } from "react";
import type { Project, User } from "./api/types";
import { api } from "./api/client";
import Header from "./components/layout/Header";
import UserSelect from "./components/users/UserSelect";
import ProjectList from "./components/projects/ProjectList";
import Board from "./components/kanban/Board";

export default function App() {
  const [users, setUsers] = useState<User[]>([]);
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [projects, setProjects] = useState<Project[]>([]);
  const [selectedProjectId, setSelectedProjectId] = useState<string | null>(null);

  useEffect(() => {
    api.getUsers().then(setUsers).catch(console.error);
    api.getProjects().then(setProjects).catch(console.error);
  }, []);

  if (!currentUser) {
    return <UserSelect users={users} onSelect={setCurrentUser} />;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Header currentUser={currentUser} onSwitchUser={() => setCurrentUser(null)} />
      <main className="p-6">
        {!selectedProjectId ? (
          <ProjectList projects={projects} onSelect={setSelectedProjectId} />
        ) : (
          <Board
            projectId={selectedProjectId}
            currentUser={currentUser}
            users={users}
            onBack={() => setSelectedProjectId(null)}
          />
        )}
      </main>
    </div>
  );
}
