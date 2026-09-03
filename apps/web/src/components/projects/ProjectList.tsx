import type { Project } from "../../api/types";

interface ProjectListProps {
  projects: Project[];
  onSelect: (id: string) => void;
}

export default function ProjectList({ projects, onSelect }: ProjectListProps) {
  return (
    <div>
      <h2 className="mb-4 text-lg font-semibold text-gray-900">Projects</h2>
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {projects.map((project) => (
          <button
            key={project.id}
            onClick={() => onSelect(project.id)}
            className="rounded-lg border border-gray-200 bg-white p-4 text-left shadow-sm transition hover:shadow-md"
          >
            <h3 className="font-medium text-gray-900">{project.name}</h3>
            {project.description && (
              <p className="mt-1 text-sm text-gray-500">{project.description}</p>
            )}
            <p className="mt-2 text-xs text-gray-400">
              {project.done_count}/{project.task_count} tasks done
            </p>
          </button>
        ))}
      </div>
    </div>
  );
}
