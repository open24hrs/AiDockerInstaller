export interface PGLiteAdapter {
    connect(): Promise<void>;
    disconnect(): Promise<void>;
    query<T = any>(sql: string, params?: any[]): Promise<T[]>;
}

export class PGLiteDatabaseAdapter implements PGLiteAdapter {
    async connect(): Promise<void> {
        // Implementation
    }

    async disconnect(): Promise<void> {
        // Implementation
    }

    async query<T = any>(sql: string, params?: any[]): Promise<T[]> {
        // Implementation
        return [];
    }
} 