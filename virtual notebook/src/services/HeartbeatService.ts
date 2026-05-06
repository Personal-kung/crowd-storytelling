/**
 * HeartbeatService.ts
 * Diegetic engagement tracking for the Virtual Notebook.
 * Logs reading cadence, translation ratios, and tactile interactions.
 */

export enum InteractionType {
  SCROLL = 'SCROLL',
  PAGE_FLIP = 'PAGE_FLIP',
  TRANSCREATE = 'TRANSCREATE',
  TACTILE_HOVER = 'TACTILE_HOVER',
  TACTILE_LONG_PRESS = 'TACTILE_LONG_PRESS',
}

interface HeartbeatPayload {
  type: InteractionType;
  timestamp: number;
  metadata?: any;
}

class HeartbeatService {
  private static instance: HeartbeatService;
  private startTime: number = Date.now();

  private constructor() {
    console.log('[HeartbeatService] Initialized at:', new Date(this.startTime).toLocaleTimeString());
  }

  public static getInstance(): HeartbeatService {
    if (!HeartbeatService.instance) {
      HeartbeatService.instance = new HeartbeatService();
    }
    return HeartbeatService.instance;
  }

  public log(type: InteractionType, metadata: any = {}): void {
    const payload: HeartbeatPayload = {
      type,
      timestamp: Date.now(),
      metadata: {
        ...metadata,
        deltaSinceStart: Date.now() - this.startTime,
      }
    };

    // Compliance: Logging to console for developer review as per directive
    console.group(`[Heartbeat] ${type}`);
    console.dir(payload);
    console.groupEnd();
  }
}

export const heartbeat = HeartbeatService.getInstance();
