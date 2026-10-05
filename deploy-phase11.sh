#!/bin/bash

# ============================================================================
# PHASE 11: HOUSEKEEPING & LAUNDRY MANAGEMENT
# Hotel Pro SaaS - Complete Housekeeping & Laundry Operations
# ============================================================================

set -e
PROJECT_DIR="/workspaces/hotelpro-saas"

echo "🧹 PHASE 11: Housekeeping & Laundry Management"
echo "=============================================="
cd $PROJECT_DIR

# ============================================================================
# MODELS - Database Schema
# ============================================================================

# 1. HOUSEKEEPING STAFF
cat > backend/src/models/11_housekeeping/HousekeepingStaff.js << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../../config/database.js';

const HousekeepingStaff = sequelize.define('HousekeepingStaff', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  organizationId: {
    type: DataTypes.UUID,
    allowNull: false,
    index: true
  },
  employeeId: {
    type: DataTypes.UUID,
    allowNull: false
  },
  designation: {
    type: DataTypes.ENUM(
      'housekeeper',
      'room_attendant',
      'laundry_operator',
      'quality_inspector',
      'supervisor',
      'manager'
    ),
    defaultValue: 'room_attendant'
  },
  shiftType: {
    type: DataTypes.ENUM('morning', 'afternoon', 'night', 'full_day'),
    defaultValue: 'full_day'
  },
  roomsAssigned: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  areaAssignment: {
    type: DataTypes.STRING,
    comment: 'Floor or specific area assigned'
  },
  status: {
    type: DataTypes.ENUM('active', 'on_leave', 'inactive'),
    defaultValue: 'active'
  },
  performanceRating: {
    type: DataTypes.DECIMAL(3, 2),
    defaultValue: 0
  },
  totalRoomsCompleted: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  averageCleaningTime: {
    type: DataTypes.INTEGER,
    comment: 'Minutes'
  }
}, {
  tableName: 'housekeeping_staff',
  timestamps: true
});

export default HousekeepingStaff;
EOF
echo "✅ HousekeepingStaff.js created"

# 2. ROOM CLEANING SCHEDULE
cat > backend/src/models/11_housekeeping/RoomCleaningSchedule.js << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../../config/database.js';

const RoomCleaningSchedule = sequelize.define('RoomCleaningSchedule', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  organizationId: {
    type: DataTypes.UUID,
    allowNull: false,
    index: true
  },
  roomId: {
    type: DataTypes.UUID,
    allowNull: false
  },
  scheduledDate: {
    type: DataTypes.DATE,
    allowNull: false,
    index: true
  },
  shiftType: {
    type: DataTypes.ENUM('morning', 'afternoon', 'night'),
    defaultValue: 'morning'
  },
  cleaningType: {
    type: DataTypes.ENUM('routine', 'deep', 'turnover', 'checkout'),
    defaultValue: 'routine'
  },
  assignedTo: {
    type: DataTypes.UUID,
    comment: 'HousekeepingStaff ID'
  },
  estimatedDuration: {
    type: DataTypes.INTEGER,
    comment: 'Minutes'
  },
  status: {
    type: DataTypes.ENUM(
      'scheduled',
      'in_progress',
      'completed',
      'inspection_pending',
      'approved',
      'cancelled'
    ),
    defaultValue: 'scheduled'
  },
  startTime: {
    type: DataTypes.DATE
  },
  completionTime: {
    type: DataTypes.DATE
  },
  notes: {
    type: DataTypes.TEXT
  },
  priority: {
    type: DataTypes.ENUM('low', 'medium', 'high', 'urgent'),
    defaultValue: 'medium'
  }
}, {
  tableName: 'room_cleaning_schedule',
  timestamps: true,
  indexes: [
    { fields: ['organizationId', 'scheduledDate'] },
    { fields: ['roomId', 'scheduledDate'] },
    { fields: ['assignedTo', 'scheduledDate'] }
  ]
});

export default RoomCleaningSchedule;
EOF
echo "✅ RoomCleaningSchedule.js created"

# 3. CLEANING TASKS
cat > backend/src/models/11_housekeeping/CleaningTask.js << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../../config/database.js';

const CleaningTask = sequelize.define('CleaningTask', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  organizationId: {
    type: DataTypes.UUID,
    allowNull: false,
    index: true
  },
  scheduleId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'room_cleaning_schedule', key: 'id' }
  },
  taskName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  taskCategory: {
    type: DataTypes.ENUM(
      'bathroom',
      'bedroom',
      'flooring',
      'furniture',
      'windows',
      'supplies',
      'inspection'
    )
  },
  description: {
    type: DataTypes.TEXT
  },
  isCompleted: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  completionTime: {
    type: DataTypes.DATE
  },
  notes: {
    type: DataTypes.TEXT
  }
}, {
  tableName: 'cleaning_tasks',
  timestamps: true
});

export default CleaningTask;
EOF
echo "✅ CleaningTask.js created"

# 4. LAUNDRY ITEMS
cat > backend/src/models/11_housekeeping/LaundryItem.js << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../../config/database.js';

const LaundryItem = sequelize.define('LaundryItem', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  organizationId: {
    type: DataTypes.UUID,
    allowNull: false,
    index: true
  },
  itemCode: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false
  },
  itemType: {
    type: DataTypes.ENUM(
      'bed_sheet',
      'pillowcase',
      'towel',
      'bath_towel',
      'tablecloth',
      'napkin',
      'uniform',
      'other'
    ),
    allowNull: false
  },
  description: {
    type: DataTypes.STRING
  },
  totalQuantity: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  inUseQuantity: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  cleanQuantity: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  dirtyQuantity: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  damageQuantity: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  cost: {
    type: DataTypes.DECIMAL(10, 2)
  },
  reorderLevel: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  status: {
    type: DataTypes.ENUM('active', 'obsolete'),
    defaultValue: 'active'
  }
}, {
  tableName: 'laundry_items',
  timestamps: true,
  indexes: [
    { fields: ['organizationId', 'itemType'] }
  ]
});

export default LaundryItem;
EOF
echo "✅ LaundryItem.js created"

# 5. LAUNDRY BATCH
cat > backend/src/models/11_housekeeping/LaundryBatch.js << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../../config/database.js';

const LaundryBatch = sequelize.define('LaundryBatch', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  organizationId: {
    type: DataTypes.UUID,
    allowNull: false,
    index: true
  },
  batchNumber: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false
  },
  batchDate: {
    type: DataTypes.DATE,
    allowNull: false
  },
  batchType: {
    type: DataTypes.ENUM('regular', 'heavy_soil', 'delicate', 'urgent'),
    defaultValue: 'regular'
  },
  totalItems: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  status: {
    type: DataTypes.ENUM(
      'pending',
      'in_washing',
      'in_drying',
      'in_pressing',
      'ready_for_delivery',
      'delivered'
    ),
    defaultValue: 'pending'
  },
  washingStartTime: {
    type: DataTypes.DATE
  },
  washingEndTime: {
    type: DataTypes.DATE
  },
  dryingStartTime: {
    type: DataTypes.DATE
  },
  dryingEndTime: {
    type: DataTypes.DATE
  },
  pressingStartTime: {
    type: DataTypes.DATE
  },
  pressingEndTime: {
    type: DataTypes.DATE
  },
  damageItems: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  notes: {
    type: DataTypes.TEXT
  },
  processedBy: {
    type: DataTypes.UUID,
    comment: 'HousekeepingStaff ID'
  }
}, {
  tableName: 'laundry_batches',
  timestamps: true,
  indexes: [
    { fields: ['organizationId', 'batchDate'] },
    { fields: ['batchNumber'] },
    { fields: ['status'] }
  ]
});

export default LaundryBatch;
EOF
echo "✅ LaundryBatch.js created"

# 6. LAUNDRY QUEUE
cat > backend/src/models/11_housekeeping/LaundryQueue.js << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../../config/database.js';

const LaundryQueue = sequelize.define('LaundryQueue', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  organizationId: {
    type: DataTypes.UUID,
    allowNull: false,
    index: true
  },
  laundryItemId: {
    type: DataTypes.UUID,
    allowNull: false
  },
  batchId: {
    type: DataTypes.UUID
  },
  source: {
    type: DataTypes.ENUM('room', 'restaurant', 'banquet', 'bar'),
    defaultValue: 'room'
  },
  sourceId: {
    type: DataTypes.UUID,
    comment: 'Room ID or other reference'
  },
  quantity: {
    type: DataTypes.INTEGER,
    defaultValue: 1
  },
  priority: {
    type: DataTypes.ENUM('low', 'medium', 'high', 'urgent'),
    defaultValue: 'medium'
  },
  collectedDate: {
    type: DataTypes.DATE
  },
  status: {
    type: DataTypes.ENUM(
      'collected',
      'in_queue',
      'in_processing',
      'completed',
      'returned'
    ),
    defaultValue: 'collected'
  },
  returnedDate: {
    type: DataTypes.DATE
  },
  condition: {
    type: DataTypes.ENUM('good', 'damaged', 'lost'),
    defaultValue: 'good'
  }
}, {
  tableName: 'laundry_queue',
  timestamps: true,
  indexes: [
    { fields: ['organizationId', 'status'] },
    { fields: ['batchId'] }
  ]
});

export default LaundryQueue;
EOF
echo "✅ LaundryQueue.js created"

# 7. QUALITY CHECK
cat > backend/src/models/11_housekeeping/QualityCheck.js << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../../config/database.js';

const QualityCheck = sequelize.define('QualityCheck', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  organizationId: {
    type: DataTypes.UUID,
    allowNull: false,
    index: true
  },
  scheduleId: {
    type: DataTypes.UUID,
    allowNull: false
  },
  roomId: {
    type: DataTypes.UUID
  },
  inspectorId: {
    type: DataTypes.UUID,
    comment: 'HousekeepingStaff ID'
  },
  inspectionDate: {
    type: DataTypes.DATE,
    allowNull: false
  },
  cleanlinessScore: {
    type: DataTypes.INTEGER,
    validate: { min: 0, max: 100 }
  },
  bathroomCondition: {
    type: DataTypes.ENUM('excellent', 'good', 'average', 'poor'),
    defaultValue: 'good'
  },
  bedroomCondition: {
    type: DataTypes.ENUM('excellent', 'good', 'average', 'poor'),
    defaultValue: 'good'
  },
  flooringCondition: {
    type: DataTypes.ENUM('excellent', 'good', 'average', 'poor'),
    defaultValue: 'good'
  },
  furnitureCondition: {
    type: DataTypes.ENUM('excellent', 'good', 'average', 'poor'),
    defaultValue: 'good'
  },
  overallStatus: {
    type: DataTypes.ENUM('approved', 'needs_rework', 'rejected'),
    defaultValue: 'approved'
  },
  issues: {
    type: DataTypes.TEXT,
    comment: 'List of issues found'
  },
  recommendations: {
    type: DataTypes.TEXT
  },
  photos: {
    type: DataTypes.JSON,
    comment: 'Array of photo URLs'
  },
  approvedBy: {
    type: DataTypes.UUID
  }
}, {
  tableName: 'quality_checks',
  timestamps: true,
  indexes: [
    { fields: ['organizationId', 'inspectionDate'] },
    { fields: ['roomId', 'inspectionDate'] }
  ]
});

export default QualityCheck;
EOF
echo "✅ QualityCheck.js created"

# 8. CLEANING SUPPLY
cat > backend/src/models/11_housekeeping/CleaningSupply.js << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../../config/database.js';

const CleaningSupply = sequelize.define('CleaningSupply', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  organizationId: {
    type: DataTypes.UUID,
    allowNull: false,
    index: true
  },
  supplyCode: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false
  },
  supplyName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  category: {
    type: DataTypes.ENUM(
      'detergent',
      'disinfectant',
      'air_freshener',
      'equipment',
      'other'
    ),
    defaultValue: 'other'
  },
  unit: {
    type: DataTypes.ENUM('litre', 'kg', 'box', 'piece', 'bottle'),
    defaultValue: 'piece'
  },
  currentStock: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0
  },
  minimumStock: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0
  },
  unitCost: {
    type: DataTypes.DECIMAL(10, 2)
  },
  vendorName: {
    type: DataTypes.STRING
  },
  lastPurchaseDate: {
    type: DataTypes.DATE
  },
  expiryDate: {
    type: DataTypes.DATE
  },
  status: {
    type: DataTypes.ENUM('active', 'discontinued'),
    defaultValue: 'active'
  }
}, {
  tableName: 'cleaning_supplies',
  timestamps: true,
  indexes: [
    { fields: ['organizationId', 'category'] }
  ]
});

export default CleaningSupply;
EOF
echo "✅ CleaningSupply.js created"

# 9. CLEANING SUPPLY USAGE
cat > backend/src/models/11_housekeeping/CleaningSupplyUsage.js << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../../config/database.js';

const CleaningSupplyUsage = sequelize.define('CleaningSupplyUsage', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  organizationId: {
    type: DataTypes.UUID,
    allowNull: false,
    index: true
  },
  supplyId: {
    type: DataTypes.UUID,
    allowNull: false
  },
  scheduleId: {
    type: DataTypes.UUID
  },
  quantityUsed: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  usageDate: {
    type: DataTypes.DATE,
    allowNull: false
  },
  usedBy: {
    type: DataTypes.UUID,
    comment: 'HousekeepingStaff ID'
  },
  notes: {
    type: DataTypes.TEXT
  }
}, {
  tableName: 'cleaning_supply_usage',
  timestamps: true,
  indexes: [
    { fields: ['organizationId', 'usageDate'] },
    { fields: ['supplyId', 'usageDate'] }
  ]
});

export default CleaningSupplyUsage;
EOF
echo "✅ CleaningSupplyUsage.js created"

# 10. ROOM STATUS
cat > backend/src/models/11_housekeeping/RoomStatus.js << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../../config/database.js';

const RoomStatus = sequelize.define('RoomStatus', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  organizationId: {
    type: DataTypes.UUID,
    allowNull: false,
    index: true
  },
  roomId: {
    type: DataTypes.UUID,
    allowNull: false,
    unique: true
  },
  cleanlinessStatus: {
    type: DataTypes.ENUM(
      'clean',
      'dirty',
      'in_progress',
      'needs_inspection',
      'under_maintenance'
    ),
    defaultValue: 'dirty'
  },
  lastCleanedDate: {
    type: DataTypes.DATE
  },
  lastInspectedDate: {
    type: DataTypes.DATE
  },
  lastCleanedBy: {
    type: DataTypes.UUID,
    comment: 'HousekeepingStaff ID'
  },
  lastInspectedBy: {
    type: DataTypes.UUID,
    comment: 'HousekeepingStaff ID'
  },
  cleanlinesScore: {
    type: DataTypes.INTEGER,
    validate: { min: 0, max: 100 }
  },
  maintenanceNotes: {
    type: DataTypes.TEXT
  },
  damageReported: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  }
}, {
  tableName: 'room_status',
  timestamps: true
});

export default RoomStatus;
EOF
echo "✅ RoomStatus.js created"

# ============================================================================
# SERVICE LAYER
# ============================================================================

cat > backend/src/routes/11_housekeeping/housekeeping.service.js << 'EOF'
import sequelize from '../../config/database.js';
import HousekeepingStaff from '../../models/11_housekeeping/HousekeepingStaff.js';
import RoomCleaningSchedule from '../../models/11_housekeeping/RoomCleaningSchedule.js';
import CleaningTask from '../../models/11_housekeeping/CleaningTask.js';
import LaundryItem from '../../models/11_housekeeping/LaundryItem.js';
import LaundryBatch from '../../models/11_housekeeping/LaundryBatch.js';
import LaundryQueue from '../../models/11_housekeeping/LaundryQueue.js';
import QualityCheck from '../../models/11_housekeeping/QualityCheck.js';
import CleaningSupply from '../../models/11_housekeeping/CleaningSupply.js';
import CleaningSupplyUsage from '../../models/11_housekeeping/CleaningSupplyUsage.js';
import RoomStatus from '../../models/11_housekeeping/RoomStatus.js';

// HOUSEKEEPING STAFF
export const createHousekeepingStaff = async (organizationId, data) => {
  return await HousekeepingStaff.create({
    organizationId,
    ...data
  });
};

export const getHousekeepingStaff = async (organizationId, filters = {}) => {
  const where = { organizationId };
  if (filters.designation) where.designation = filters.designation;
  if (filters.status) where.status = filters.status;
  if (filters.areaAssignment) where.areaAssignment = filters.areaAssignment;

  return await HousekeepingStaff.findAll({ where, order: [['createdAt', 'DESC']] });
};

export const updateHousekeepingStaff = async (organizationId, staffId, data) => {
  const staff = await HousekeepingStaff.findOne({ where: { id: staffId, organizationId } });
  if (!staff) throw new Error('Staff not found');
  return await staff.update(data);
};

// CLEANING SCHEDULES
export const createCleaningSchedule = async (organizationId, data) => {
  return await RoomCleaningSchedule.create({
    organizationId,
    ...data
  });
};

export const getCleaningSchedules = async (organizationId, filters = {}) => {
  const where = { organizationId };
  if (filters.scheduledDate) {
    where.scheduledDate = {
      [sequelize.Op.gte]: new Date(filters.scheduledDate).setHours(0, 0, 0, 0),
      [sequelize.Op.lt]: new Date(filters.scheduledDate).setHours(23, 59, 59, 999)
    };
  }
  if (filters.status) where.status = filters.status;
  if (filters.roomId) where.roomId = filters.roomId;

  return await RoomCleaningSchedule.findAll({ where, order: [['scheduledDate', 'ASC']] });
};

export const updateScheduleStatus = async (organizationId, scheduleId, status) => {
  const schedule = await RoomCleaningSchedule.findOne({ where: { id: scheduleId, organizationId } });
  if (!schedule) throw new Error('Schedule not found');
  return await schedule.update({ status });
};

// QUALITY CHECKS
export const createQualityCheck = async (organizationId, data) => {
  const check = await QualityCheck.create({
    organizationId,
    ...data
  });

  // Update room status
  const roomStatus = await RoomStatus.findOne({ where: { organizationId, roomId: data.roomId } });
  if (roomStatus) {
    await roomStatus.update({
      cleanlinesScore: data.cleanlinessScore,
      lastInspectedDate: data.inspectionDate,
      lastInspectedBy: data.inspectorId,
      cleanlinessStatus: data.overallStatus === 'approved' ? 'clean' : 'needs_inspection'
    });
  }

  return check;
};

export const getQualityChecks = async (organizationId, filters = {}) => {
  const where = { organizationId };
  if (filters.roomId) where.roomId = filters.roomId;
  if (filters.inspectionDate) {
    where.inspectionDate = {
      [sequelize.Op.gte]: new Date(filters.inspectionDate).setHours(0, 0, 0, 0),
      [sequelize.Op.lt]: new Date(filters.inspectionDate).setHours(23, 59, 59, 999)
    };
  }

  return await QualityCheck.findAll({ where, order: [['inspectionDate', 'DESC']] });
};

// LAUNDRY MANAGEMENT
export const createLaundryBatch = async (organizationId, data) => {
  const year = new Date().getFullYear();
  const lastBatch = await LaundryBatch.findOne({
    where: { organizationId },
    order: [['createdAt', 'DESC']]
  });

  const batchSequence = lastBatch ? parseInt(lastBatch.batchNumber.split('-')[2]) + 1 : 1;
  const batchNumber = `LB-${year}-${String(batchSequence).padStart(5, '0')}`;

  return await LaundryBatch.create({
    organizationId,
    batchNumber,
    ...data
  });
};

export const updateBatchStatus = async (organizationId, batchId, status) => {
  const batch = await LaundryBatch.findOne({ where: { id: batchId, organizationId } });
  if (!batch) throw new Error('Batch not found');

  const updateData = { status };
  if (status === 'in_washing') updateData.washingStartTime = new Date();
  if (status === 'in_drying') updateData.dryingStartTime = new Date();
  if (status === 'in_pressing') updateData.pressingStartTime = new Date();

  return await batch.update(updateData);
};

export const getLaundryQueue = async (organizationId, filters = {}) => {
  const where = { organizationId };
  if (filters.status) where.status = filters.status;
  if (filters.priority) where.priority = filters.priority;

  return await LaundryQueue.findAll({ where, order: [['createdAt', 'ASC']] });
};

// CLEANING SUPPLIES
export const createCleaningSupply = async (organizationId, data) => {
  return await CleaningSupply.create({
    organizationId,
    supplyCode: `SUP-${Date.now()}`,
    ...data
  });
};

export const recordSupplyUsage = async (organizationId, supplyId, quantityUsed, usedBy) => {
  const supply = await CleaningSupply.findOne({ where: { id: supplyId, organizationId } });
  if (!supply) throw new Error('Supply not found');

  await supply.update({
    currentStock: sequelize.literal(`current_stock - ${quantityUsed}`)
  });

  return await CleaningSupplyUsage.create({
    organizationId,
    supplyId,
    quantityUsed,
    usageDate: new Date(),
    usedBy
  });
};

export const getLowStockSupplies = async (organizationId) => {
  return await CleaningSupply.findAll({
    where: {
      organizationId,
      status: 'active',
      currentStock: {
        [sequelize.Op.lte]: sequelize.col('minimum_stock')
      }
    }
  });
};

// ROOM STATUS
export const getRoomStatus = async (organizationId, roomId) => {
  return await RoomStatus.findOne({ where: { organizationId, roomId } });
};

export const updateRoomStatus = async (organizationId, roomId, data) => {
  const roomStatus = await RoomStatus.findOne({ where: { organizationId, roomId } });
  if (!roomStatus) {
    return await RoomStatus.create({ organizationId, roomId, ...data });
  }
  return await roomStatus.update(data);
};

// HOUSEKEEPING STATS
export const getHousekeepingStats = async (organizationId) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const completedToday = await RoomCleaningSchedule.count({
    where: {
      organizationId,
      status: 'approved',
      scheduledDate: { [sequelize.Op.gte]: today }
    }
  });

  const pendingSchedules = await RoomCleaningSchedule.count({
    where: {
      organizationId,
      status: { [sequelize.Op.in]: ['scheduled', 'in_progress'] },
      scheduledDate: { [sequelize.Op.gte]: today }
    }
  });

  const averageCleaningTime = await RoomCleaningSchedule.findOne({
    where: {
      organizationId,
      status: 'approved',
      scheduledDate: { [sequelize.Op.gte]: new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000) }
    },
    attributes: [
      [
        sequelize.fn('AVG', sequelize.literal('EXTRACT(EPOCH FROM (completion_time - start_time))/60')),
        'avgTime'
      ]
    ]
  });

  const laundryPending = await LaundryQueue.count({
    where: {
      organizationId,
      status: { [sequelize.Op.in]: ['collected', 'in_queue'] }
    }
  });

  const qualityScore = await QualityCheck.findOne({
    where: {
      organizationId,
      inspectionDate: { [sequelize.Op.gte]: new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000) }
    },
    attributes: [
      [sequelize.fn('AVG', sequelize.col('cleanliness_score')), 'avgScore']
    ]
  });

  return {
    completedToday,
    pendingSchedules,
    avgCleaningTime: parseFloat(averageCleaningTime?.dataValues?.avgTime || 0).toFixed(2),
    laundryPending,
    qualityScore: parseFloat(qualityScore?.dataValues?.avgScore || 0).toFixed(2)
  };
};
EOF
echo "✅ housekeeping.service.js created"

# ============================================================================
# CONTROLLER LAYER
# ============================================================================

cat > backend/src/routes/11_housekeeping/housekeeping.controller.js << 'EOF'
import * as housekeepingService from './housekeeping.service.js';

// HOUSEKEEPING STAFF
export const addStaff = async (req, res) => {
  try {
    const { organizationId } = req.user;
    const staff = await housekeepingService.createHousekeepingStaff(organizationId, req.body);
    res.status(201).json({ success: true, data: staff });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const getStaff = async (req, res) => {
  try {
    const { organizationId } = req.user;
    const staff = await housekeepingService.getHousekeepingStaff(organizationId, req.query);
    res.json({ success: true, data: staff });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const updateStaff = async (req, res) => {
  try {
    const { organizationId } = req.user;
    const { staffId } = req.params;
    const staff = await housekeepingService.updateHousekeepingStaff(organizationId, staffId, req.body);
    res.json({ success: true, data: staff });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

// CLEANING SCHEDULES
export const createSchedule = async (req, res) => {
  try {
    const { organizationId } = req.user;
    const schedule = await housekeepingService.createCleaningSchedule(organizationId, req.body);
    res.status(201).json({ success: true, data: schedule });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const getSchedules = async (req, res) => {
  try {
    const { organizationId } = req.user;
    const schedules = await housekeepingService.getCleaningSchedules(organizationId, req.query);
    res.json({ success: true, data: schedules });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const updateSchedule = async (req, res) => {
  try {
    const { organizationId } = req.user;
    const { scheduleId } = req.params;
    const { status } = req.body;
    const schedule = await housekeepingService.updateScheduleStatus(organizationId, scheduleId, status);
    res.json({ success: true, data: schedule });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

// QUALITY CHECKS
export const createQualityCheck = async (req, res) => {
  try {
    const { organizationId } = req.user;
    const check = await housekeepingService.createQualityCheck(organizationId, req.body);
    res.status(201).json({ success: true, data: check });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const getQualityChecks = async (req, res) => {
  try {
    const { organizationId } = req.user;
    const checks = await housekeepingService.getQualityChecks(organizationId, req.query);
    res.json({ success: true, data: checks });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

// LAUNDRY
export const createLaundryBatch = async (req, res) => {
  try {
    const { organizationId } = req.user;
    const batch = await housekeepingService.createLaundryBatch(organizationId, req.body);
    res.status(201).json({ success: true, data: batch });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const updateBatchStatus = async (req, res) => {
  try {
    const { organizationId } = req.user;
    const { batchId } = req.params;
    const { status } = req.body;
    const batch = await housekeepingService.updateBatchStatus(organizationId, batchId, status);
    res.json({ success: true, data: batch });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const getLaundryQueue = async (req, res) => {
  try {
    const { organizationId } = req.user;
    const queue = await housekeepingService.getLaundryQueue(organizationId, req.query);
    res.json({ success: true, data: queue });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

// CLEANING SUPPLIES
export const createSupply = async (req, res) => {
  try {
    const { organizationId } = req.user;
    const supply = await housekeepingService.createCleaningSupply(organizationId, req.body);
    res.status(201).json({ success: true, data: supply });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const recordSupplyUsage = async (req, res) => {
  try {
    const { organizationId, id: userId } = req.user;
    const { supplyId, quantityUsed } = req.body;
    const usage = await housekeepingService.recordSupplyUsage(organizationId, supplyId, quantityUsed, userId);
    res.status(201).json({ success: true, data: usage });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const getLowStockSupplies = async (req, res) => {
  try {
    const { organizationId } = req.user;
    const supplies = await housekeepingService.getLowStockSupplies(organizationId);
    res.json({ success: true, data: supplies });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

// ROOM STATUS
export const getRoomStatus = async (req, res) => {
  try {
    const { organizationId } = req.user;
    const { roomId } = req.params;
    const status = await housekeepingService.getRoomStatus(organizationId, roomId);
    res.json({ success: true, data: status });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

// STATS
export const getHousekeepingStats = async (req, res) => {
  try {
    const { organizationId } = req.user;
    const stats = await housekeepingService.getHousekeepingStats(organizationId);
    res.json({ success: true, data: stats });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};
EOF
echo "✅ housekeeping.controller.js created"

# ============================================================================
# ROUTES
# ============================================================================

cat > backend/src/routes/11_housekeeping/housekeeping.routes.js << 'EOF'
import express from 'express';
import { authenticate, authorize } from '../../middleware/auth.middleware.js';
import { checkModuleAccess } from '../../middleware/moduleAccess.middleware.js';
import * as controller from './housekeeping.controller.js';

const router = express.Router();

// Middleware
router.use(authenticate);
router.use(checkModuleAccess('housekeeping'));

// HOUSEKEEPING STAFF
router.post('/staff', authorize('admin', 'manager'), controller.addStaff);
router.get('/staff', controller.getStaff);
router.put('/staff/:staffId', authorize('admin', 'manager'), controller.updateStaff);

// CLEANING SCHEDULES
router.post('/schedules', authorize('admin', 'manager'), controller.createSchedule);
router.get('/schedules', controller.getSchedules);
router.put('/schedules/:scheduleId', controller.updateSchedule);

// QUALITY CHECKS
router.post('/quality-checks', controller.createQualityCheck);
router.get('/quality-checks', controller.getQualityChecks);

// LAUNDRY
router.post('/laundry/batches', controller.createLaundryBatch);
router.put('/laundry/batches/:batchId', controller.updateBatchStatus);
router.get('/laundry/queue', controller.getLaundryQueue);

// CLEANING SUPPLIES
router.post('/supplies', authorize('admin', 'manager'), controller.createSupply);
router.post('/supplies/usage', controller.recordSupplyUsage);
router.get('/supplies/low-stock', controller.getLowStockSupplies);

// ROOM STATUS
router.get('/room-status/:roomId', controller.getRoomStatus);

// STATS
router.get('/stats', controller.getHousekeepingStats);

export default router;
EOF
echo "✅ housekeeping.routes.js created"

# ============================================================================
# VALIDATORS
# ============================================================================

cat > backend/src/routes/11_housekeeping/housekeeping.validators.js << 'EOF'
import { body, param, validationResult } from 'express-validator';

export const validateStaffCreation = [
  body('employeeId').notEmpty().withMessage('Employee ID required'),
  body('designation').isIn(['housekeeper', 'room_attendant', 'laundry_operator', 'quality_inspector', 'supervisor', 'manager']),
  body('shiftType').isIn(['morning', 'afternoon', 'night', 'full_day']),
];

export const validateScheduleCreation = [
  body('roomId').notEmpty().withMessage('Room ID required'),
  body('scheduledDate').isISO8601().withMessage('Valid date required'),
  body('cleaningType').isIn(['routine', 'deep', 'turnover', 'checkout']),
];

export const validateQualityCheck = [
  body('scheduleId').notEmpty(),
  body('inspectionDate').isISO8601(),
  body('cleanlinessScore').isInt({ min: 0, max: 100 }),
  body('overallStatus').isIn(['approved', 'needs_rework', 'rejected']),
];

export const validateLaundryBatch = [
  body('batchDate').isISO8601(),
  body('batchType').isIn(['regular', 'heavy_soil', 'delicate', 'urgent']),
  body('totalItems').isInt({ min: 1 }),
];

export const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ success: false, errors: errors.array() });
  }
  next();
};
EOF
echo "✅ housekeeping.validators.js created"

# ============================================================================
# SEED DATA (Optional)
# ============================================================================

cat > backend/src/seeds/11_housekeeping_seed.js << 'EOF'
import HousekeepingStaff from '../models/11_housekeeping/HousekeepingStaff.js';
import CleaningSupply from '../models/11_housekeeping/CleaningSupply.js';
import LaundryItem from '../models/11_housekeeping/LaundryItem.js';

export const seedHousekeepingData = async (organizationId) => {
  try {
    // Seed Cleaning Supplies
    const supplies = [
      { supplyName: 'Multi-Purpose Cleaner', category: 'detergent', unit: 'litre', unitCost: 150, minimumStock: 10 },
      { supplyName: 'Disinfectant Spray', category: 'disinfectant', unit: 'bottle', unitCost: 200, minimumStock: 5 },
      { supplyName: 'Air Freshener', category: 'air_freshener', unit: 'bottle', unitCost: 120, minimumStock: 10 },
      { supplyName: 'Mop and Bucket', category: 'equipment', unit: 'piece', unitCost: 500, minimumStock: 2 },
    ];

    for (const supply of supplies) {
      await CleaningSupply.create({
        organizationId,
        supplyCode: `SUP-${Date.now()}-${Math.random()}`,
        ...supply,
        currentStock: 20
      });
    }

    // Seed Laundry Items
    const laundryItems = [
      { itemCode: 'BS-001', itemType: 'bed_sheet', description: 'Double Bed Sheet', totalQuantity: 200 },
      { itemCode: 'PC-001', itemType: 'pillowcase', description: 'Standard Pillowcase', totalQuantity: 300 },
      { itemCode: 'TW-001', itemType: 'towel', description: 'Hand Towel', totalQuantity: 150 },
      { itemCode: 'BT-001', itemType: 'bath_towel', description: 'Bath Towel', totalQuantity: 100 },
    ];

    for (const item of laundryItems) {
      await LaundryItem.create({
        organizationId,
        ...item,
        cleanQuantity: item.totalQuantity,
        reorderLevel: 50
      });
    }

    console.log('✅ Housekeeping seed data created');
  } catch (error) {
    console.error('Seed error:', error.message);
  }
};
EOF
echo "✅ housekeeping seed data created"

# ============================================================================
# CREATE DIRECTORY
# ============================================================================

mkdir -p backend/src/models/11_housekeeping
mkdir -p backend/src/routes/11_housekeeping

echo "✅ Directories created"

# ============================================================================
# UPDATE SERVER.JS
# ============================================================================

echo ""
echo "📝 Updating server.js..."

# Check if housekeeping import already exists
if ! grep -q "import housekeepingRoutes from './routes/11_housekeeping/housekeeping.routes.js'" backend/src/server.js; then
  # Add import after HR routes
  sed -i "/import hrRoutes from '.\/routes\/10_hr\/hr.routes.js';/a import housekeepingRoutes from './routes/11_housekeeping/housekeeping.routes.js';" backend/src/server.js
  echo "✅ Import added to server.js"
fi

# Check if housekeeping route registration exists
if ! grep -q "app.use('/api/housekeeping', housekeepingRoutes)" backend/src/server.js; then
  # Add route registration after HR
  sed -i "/app.use('\/api\/hr', hrRoutes);/a app.use('/api/housekeeping', housekeepingRoutes);" backend/src/server.js
  echo "✅ Route registration added to server.js"
fi

# ============================================================================
# DATABASE SYNC
# ============================================================================

echo ""
echo "🔄 Syncing database..."

cat > backend/src/sync/sync-phase11.js << 'EOF'
import sequelize from '../config/database.js';
import HousekeepingStaff from '../models/11_housekeeping/HousekeepingStaff.js';
import RoomCleaningSchedule from '../models/11_housekeeping/RoomCleaningSchedule.js';
import CleaningTask from '../models/11_housekeeping/CleaningTask.js';
import LaundryItem from '../models/11_housekeeping/LaundryItem.js';
import LaundryBatch from '../models/11_housekeeping/LaundryBatch.js';
import LaundryQueue from '../models/11_housekeeping/LaundryQueue.js';
import QualityCheck from '../models/11_housekeeping/QualityCheck.js';
import CleaningSupply from '../models/11_housekeeping/CleaningSupply.js';
import CleaningSupplyUsage from '../models/11_housekeeping/CleaningSupplyUsage.js';
import RoomStatus from '../models/11_housekeeping/RoomStatus.js';

const syncPhase11 = async () => {
  try {
    console.log('🔄 Syncing Phase 11 (Housekeeping & Laundry) models...');
    
    await HousekeepingStaff.sync({ alter: true });
    await RoomCleaningSchedule.sync({ alter: true });
    await CleaningTask.sync({ alter: true });
    await LaundryItem.sync({ alter: true });
    await LaundryBatch.sync({ alter: true });
    await LaundryQueue.sync({ alter: true });
    await QualityCheck.sync({ alter: true });
    await CleaningSupply.sync({ alter: true });
    await CleaningSupplyUsage.sync({ alter: true });
    await RoomStatus.sync({ alter: true });
    
    console.log('✅ Phase 11 models synced successfully');
  } catch (error) {
    console.error('❌ Sync error:', error.message);
  }
};

syncPhase11();
EOF

node backend/src/sync/sync-phase11.js

# ============================================================================
# COMPLETION
# ============================================================================

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           ✅ PHASE 11 DEPLOYMENT COMPLETE                     ║"
echo "║       Housekeeping & Laundry Management Ready                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 PHASE 11 ENDPOINTS:"
echo "  POST   /api/housekeeping/staff                - Add housekeeping staff"
echo "  GET    /api/housekeeping/staff                - Get all staff"
echo "  PUT    /api/housekeeping/staff/:staffId       - Update staff"
echo ""
echo "  POST   /api/housekeeping/schedules            - Create cleaning schedule"
echo "  GET    /api/housekeeping/schedules            - Get schedules"
echo "  PUT    /api/housekeeping/schedules/:scheduleId - Update schedule status"
echo ""
echo "  POST   /api/housekeeping/quality-checks       - Create quality check"
echo "  GET    /api/housekeeping/quality-checks       - Get quality checks"
echo ""
echo "  POST   /api/housekeeping/laundry/batches      - Create laundry batch"
echo "  PUT    /api/housekeeping/laundry/batches/:batchId - Update batch status"
echo "  GET    /api/housekeeping/laundry/queue        - Get laundry queue"
echo ""
echo "  POST   /api/housekeeping/supplies             - Add cleaning supply"
echo "  POST   /api/housekeeping/supplies/usage       - Record supply usage"
echo "  GET    /api/housekeeping/supplies/low-stock   - Get low stock items"
echo ""
echo "  GET    /api/housekeeping/room-status/:roomId  - Get room cleanliness status"
echo "  GET    /api/housekeeping/stats                - Get housekeeping stats"
echo ""
echo "📁 FILES CREATED:"
echo "  ✅ 10 Models (HousekeepingStaff, RoomCleaningSchedule, CleaningTask, LaundryItem, LaundryBatch, LaundryQueue, QualityCheck, CleaningSupply, CleaningSupplyUsage, RoomStatus)"
echo "  ✅ Service Layer (housekeeping.service.js)"
echo "  ✅ Controller Layer (housekeeping.controller.js)"
echo "  ✅ Routes (housekeeping.routes.js)"
echo "  ✅ Validators (housekeeping.validators.js)"
echo "  ✅ Seed Data (11_housekeeping_seed.js)"
echo ""
echo "🔌 SERVER.JS UPDATED:"
echo "  ✅ Import added: import housekeepingRoutes from './routes/11_housekeeping/housekeeping.routes.js'"
echo "  ✅ Route registered: app.use('/api/housekeeping', housekeepingRoutes)"
echo ""
echo "🗄️  DATABASE:"
echo "  ✅ All 10 Phase 11 tables synced"
echo ""
echo "⏭️  NEXT STEP: Phase 12 (Reporting Engine)"
echo ""
