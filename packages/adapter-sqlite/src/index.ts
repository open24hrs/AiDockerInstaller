export interface SQLiteAdapter {
    connect(): Promise<void>;
    disconnect(): Promise<void>;
    query<T = any>(sql: string, params?: any[]): Promise<T[]>;
}

export class SQLiteDatabaseAdapter implements SQLiteAdapter {
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