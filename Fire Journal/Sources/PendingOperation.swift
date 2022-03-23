//
//  PendingOperation.swift
//  DashboardTest
//
//  Created by DuRand Jones on 2/7/20.
//  Copyright © 2020 inSky LE. All rights reserved.
//

import Foundation

class PendingOperations {
    //    lazy var nfirsIncidentTypeInProgress: [IndexPath: Operation] = [:]
    lazy var nfirsIncidentTypeQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "NFIRS INCIDENT TYPE queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class ResourcesPendingOperations {
    lazy var resourcesTypeQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "RESOURCES TYPE queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class WeatherPendingOperations {
    lazy var weatherTypeQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "WEATHER TYPE queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class UpdateLocationsSCPendingOperations {
    lazy var locationsSCTypeQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "LocationToLocationSC queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class ARCFormPendingOperations {
    lazy var arcFormTypeQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "ARC Form to Cloud queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class TagsPendingOperation {
    lazy var tagsReloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "tags reload queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class ResourcePendingOperations {
    lazy var resourcesPendingQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "resources pending queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class ResourceReloadPendingOperation {
    lazy var resourcesReloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "resources reload queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class RankPendingOperation {
    lazy var rankReloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "rank reload queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class PlatoonPendingOperation {
    lazy var platoonReloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "plaoon reload queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class StreetTypePendingOperation {
    lazy var streetTypeReloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "street type reload queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class LocalIncidentTypePendingOperation {
    lazy var localIncidentTypeReloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "local incident type reload queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class UserSyncOperation {
    lazy var userSyncQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "user sync queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class JournalSyncOperation {
    lazy var journalSyncQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "journal sync queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class IncidentSyncOperation {
    lazy var incidentSyncQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "incident sync queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class UserTimeSyncOperation {
    lazy var userTimeSyncQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "user time sync queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class ICS214SyncOperation {
    lazy var ics214SyncQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "ics214 sync queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class ArcFormSyncOperation {
    lazy var arcFormSyncQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "arc Form sync queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class UserAttendeeSyncOperation {
    lazy var userAttendeeSyncQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "user attendee sync queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class ICS214ActivityLogSyncOperation {
    lazy var ics214ActivityLogSyncQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "ICS214ActivityLog sync queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class ICS214PersonalSyncOperation {
    lazy var ics214PersonalSyncQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "ICS214Personal sync queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class FDResourcesSyncOperation {
    lazy var fdResourcesSyncQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "FDResources sync queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}

class VersionPendingOperation {
    lazy var versionPendingQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "version pending queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
}
