// ============================================
// 🔐 ROLE & PERMISSION MODELS - RBAC
// ============================================

import { DataTypes } from 'sequelize';

export const defineRoleModel = (sequelize) => {
  const Role = sequelize.define('Role', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    organizationId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'organizations',
        key: 'id'
      }
    },
    name: {
      type: DataTypes.STRING(100),
      allowNull: false,
      validate: {
        len: [2, 100]
      }
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    isSystemRole: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      comment: 'Cannot be deleted if true'
    },
    createdAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    },
    updatedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'roles',
    timestamps: true,
    indexes: [
      {
        fields: ['organizationId', 'name'],
        unique: true
      }
    ]
  });

  return Role;
};

export const defineRolePermissionModel = (sequelize) => {
  const RolePermission = sequelize.define('RolePermission', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    roleId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'roles',
        key: 'id'
      }
    },
    moduleName: {
      type: DataTypes.STRING(100),
      allowNull: false,
      comment: 'e.g., pms, restaurant_pos, billing'
    },
    permission: {
      type: DataTypes.STRING(50),
      allowNull: false,
      comment: 'e.g., VIEW, CREATE, EDIT, DELETE, APPROVE'
    },
    createdAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'role_permissions',
    timestamps: false,
    indexes: [
      {
        fields: ['roleId', 'moduleName', 'permission'],
        unique: true
      }
    ]
  });

  return RolePermission;
};

// ============================================
// DEFAULT PERMISSIONS BY ROLE
// ============================================

export const DEFAULT_ROLE_PERMISSIONS = {
  'SUPER_ADMIN': {
    description: 'Full system access',
    permissions: {
      'authentication': ['VIEW', 'CREATE', 'EDIT', 'DELETE', 'MANAGE_SETTINGS'],
      'dashboard': ['VIEW'],
      'pms': ['VIEW', 'CREATE', 'EDIT', 'DELETE', 'APPROVE'],
      'restaurant_pos': ['VIEW', 'CREATE', 'EDIT', 'DELETE'],
      'bar_pos': ['VIEW', 'CREATE', 'EDIT', 'DELETE'],
      'banquet': ['VIEW', 'CREATE', 'EDIT', 'DELETE', 'APPROVE'],
      'housekeeping': ['VIEW', 'CREATE', 'EDIT', 'DELETE'],
      'inventory': ['VIEW', 'CREATE', 'EDIT', 'DELETE'],
      'accounts_gst': ['VIEW', 'CREATE', 'EDIT', 'DELETE'],
      'hr': ['VIEW', 'CREATE', 'EDIT', 'DELETE'],
      'reports': ['VIEW', 'EXPORT'],
      'integrations': ['VIEW', 'CREATE', 'EDIT', 'DELETE', 'MANAGE_SETTINGS']
    }
  },
  
  'OWNER': {
    description: 'Organization owner',
    permissions: {
      'dashboard': ['VIEW'],
      'pms': ['VIEW', 'APPROVE'],
      'restaurant_pos': ['VIEW', 'APPROVE'],
      'banquet': ['VIEW', 'APPROVE'],
      'billing': ['VIEW', 'APPROVE'],
      'accounts_gst': ['VIEW'],
      'reports': ['VIEW', 'EXPORT'],
      'integrations': ['VIEW', 'MANAGE_SETTINGS']
    }
  },

  'GENERAL_MANAGER': {
    description: 'Hotel general manager',
    permissions: {
      'dashboard': ['VIEW'],
      'pms': ['VIEW', 'CREATE', 'EDIT', 'APPROVE'],
      'restaurant_pos': ['VIEW', 'APPROVE'],
      'housekeeping': ['VIEW', 'EDIT'],
      'reports': ['VIEW', 'EXPORT'],
      'accounts_gst': ['VIEW']
    }
  },

  'FRONT_OFFICE_MANAGER': {
    description: 'Front office manager',
    permissions: {
      'dashboard': ['VIEW'],
      'pms': ['VIEW', 'CREATE', 'EDIT'],
      'housekeeping': ['VIEW'],
      'billing': ['VIEW', 'CREATE']
    }
  },

  'RECEPTIONIST': {
    description: 'Front desk staff',
    permissions: {
      'pms': ['VIEW', 'CREATE'],
      'billing': ['VIEW'],
      'guests': ['VIEW']
    }
  },

  'RESTAURANT_MANAGER': {
    description: 'Restaurant manager',
    permissions: {
      'dashboard': ['VIEW'],
      'restaurant_pos': ['VIEW', 'CREATE', 'EDIT', 'APPROVE'],
      'inventory': ['VIEW'],
      'billing': ['VIEW'],
      'reports': ['VIEW', 'EXPORT']
    }
  },

  'WAITER': {
    description: 'Waiter/Server',
    permissions: {
      'restaurant_pos': ['VIEW', 'CREATE']
    }
  },

  'CHEF': {
    description: 'Chef',
    permissions: {
      'restaurant_pos': ['VIEW', 'EDIT'],
      'inventory': ['VIEW']
    }
  },

  'HOUSEKEEPING_STAFF': {
    description: 'Housekeeping staff',
    permissions: {
      'housekeeping': ['VIEW', 'EDIT']
    }
  },

  'STAFF': {
    description: 'General staff',
    permissions: {
      'dashboard': ['VIEW']
    }
  },

  'GUEST': {
    description: 'Guest user',
    permissions: {
      'guests': ['VIEW']
    }
  }
};

export default {
  defineRoleModel,
  defineRolePermissionModel,
  DEFAULT_ROLE_PERMISSIONS
};
