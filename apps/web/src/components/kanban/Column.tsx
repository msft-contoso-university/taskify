import { Droppable } from "@hello-pangea/dnd";
import type { Task, TaskStatus } from "../../api/types";
import Card from "./Card";

interface ColumnProps {
  status: TaskStatus;
  label: string;
  tasks: Task[];
  onTaskClick: (id: string) => void;
}

export default function Column({ status, label, tasks, onTaskClick }: ColumnProps) {
  return (
    <div className="rounded-lg bg-gray-100 p-3">
      <h3 className="mb-3 text-sm font-semibold text-gray-700">
        {label} <span className="text-gray-400">({tasks.length})</span>
      </h3>
      <Droppable droppableId={status}>
        {(provided) => (
          <div ref={provided.innerRef} {...provided.droppableProps} className="flex min-h-[60px] flex-col gap-2">
            {tasks.map((task, index) => (
              <Card key={task.id} task={task} index={index} onClick={() => onTaskClick(task.id)} />
            ))}
            {provided.placeholder}
          </div>
        )}
      </Droppable>
    </div>
  );
}
