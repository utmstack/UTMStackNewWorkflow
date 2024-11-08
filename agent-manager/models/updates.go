package models

import (
	"encoding/json"
)

type InfoResponse struct {
	Display  string          `json:"display-ribbon-on-profiles"`
	Git      json.RawMessage `json:"git"`
	Build    Build           `json:"build"`
	Profiles []string        `json:"activeProfiles"`
}

type Build struct {
	Artifact string `json:"artifact"`
	Name     string `json:"name"`
	Time     string `json:"time"`
	Version  string `json:"version"`
	Group    string `json:"group"`
}

type DataVersions struct {
	Versions []Version `json:"versions"`
}

type Version struct {
	MasterVersion       string `json:"master_version"`
	ServiceVersion      string `json:"service_version,omitempty"`
	InstallerVersion    string `json:"installer_version,omitempty"`
	DependenciesVersion string `json:"dependencies_version,omitempty"`
}

type Dependency struct {
	Name                  string
	DownloadPath          string
	CurrentServiceVersion string
	LatestServiceVersion  string
	CurrentDependVersion  string
	LatestDependVersion   string
}

type DependencyUpdateResponse struct {
	Message     string `json:"message"`
	Version     string `json:"version"`
	TotalSize   int64  `json:"totalSize"`
	PartIndex   string `json:"partIndex,omitempty"`
	NParts      int    `json:"nParts,omitempty"`
	FileContent []byte `json:"fileContent,omitempty"`
}
