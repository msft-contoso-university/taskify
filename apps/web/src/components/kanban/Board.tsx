import { useEffect, useState } from "react";
import { DragDropContext, type DropResult } from "@hello-pangea/dnd";
import type { Task, TaskStatus, User } from "../../api/types";
import { api } from "../../api/client";
import Column from "./Column";
import TaskDetail from "./TaskDetail";

interface BoardProps {
  projectId: string;
  currentUser: User;
  users: User[];
  onBack: () => void;
}

const STATUSES: { key: TaskStatus; label: string }[] = [
  { key: "todo", label: "To Do" },
  { key: "in_progress", label: "In Progress" },
  { key: "in_review", label: "In Review" },
  { key: "done", label: "Done" },
];

export default function Board({ projectId, currentUser, users, onBack }: BoardProps) {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [selectedTaskId, setSelectedTaskId] = useState<string | null>(null);

  const load = () => api.getTasks(projectId).then(setTasks).catch(console.error);

  useEffect(() => {
    load();
  }, [projectId]);

  const onDragEnd = async (result: DropResult) => {
    const { destination, draggableId } = result;
    if (!destination) return;

    const newStatus = destination.droppableId as TaskStatus;
    const newPosition = destination.index;

    setTasks((prev) =>
      prev.map((t) => (t.id === draggableId ? { ...t, status: newStatus, position: newPosition } : t))
    );

    try {
      await api.updateTaskStatus(draggableId, newStatus, newPosition);
    } catch (err) {
      console.error(err);
      load();
    }
  };

  const selectedTask = tasks.find((t) => t.id === selectedTaskId) ?? null;

  return (
    <div>
      <button onClick={onBack} className="mb-4 text-sm text-indigo-600 hover:underline">
        ← Back to projects
      </button>
      <DragDropContext onDragEnd={onDragEnd}>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {STATUSES.map(({ key, label }) => (
            <Column
              key={key}
              status={key}
              label={label}
              tasks={tasks.filter((t) => t.status === key).sort((a, b) => a.position - b.position)}
              onTaskClick={setSelectedTaskId}
            />
          ))}
        </div>
      </DragDropContext>
      {selectedTask && (
        <TaskDetail
          task={selectedTask}
          currentUser={currentUser}
          users={users}
          onClose={() => setSelectedTaskId(null)}
          onChanged={load}
        />
      )}
    </div>
  );
}
