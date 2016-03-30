// I could make a collection of these and move them all into private/

LicenseCategory = [
  {
    label: "Copyleft",
    value: "copyleft",
    description: "The right to freely distribute copies and modified versions of a work with the stipulation that the same rights be preserved in derivative works down the line"
  },
  {label: "Free Software", value: "free" },
  {label: "Proprietary Software", value: "closed" },
  {label: "Open Source Software", value: "opensource" },
  {label: "Creative Commons", value: "cc" },
  {
    label: "FSF approved",
    value: "fsf",
    description: "Approved by the 'Free Software Foundation' against the 'Free Software Definition'"
  },
  {
    label: "OSI approved",
    value: "osi",
    description: "Approved by the 'Open Source Initiative' against the 'Open Source Definition'"
  },
  {
    label: "DFSG compliant",
    value: "dfsg",
    description: "Compilent to the Debian Free Software Guidelines"
  },
]

LicenseReleation = [
  {label: "Dynamic Linking", value: "dynamic" },
  {label: "Static Linking", value: "static"},
  {label: "Plugin", value: "plugin"},
  {label: "Documentation", value: "doc"},
  {label: "RemoteAPI", value: "remote"},
  {label: "Source", value: "source"}
]

LicenseCompatibility = [
  {
    label:"Not Compatible",
    value: "notcompatible",
    description: "It is not possible to use together artifacts released using these two licenses."
  },
  {
    label:"Compatible",
    value: "compatible",
    description: "Two artifacts can be used and redistributed together."
  },
  {
    label: "Linking",
    value: "linking",
    description: "Two artifacts can be linked together."
  }
]

LicenseCharacteristic = {
  "limitations": [
    {
      "tag": "trademark-use",
      "description": "While this may be implicitly true of all licenses, this license explicitly states that it does NOT grant you any rights in the trademarks or other marks of contributors.",
      "label": "Trademark Use"
    },
    {
      "tag": "no-liability",
      "description": "Software is provided without warranty and the software author/license owner cannot be held liable for damages.",
      "label": "Hold Liable"
    },
    {
      "tag": "patent-use",
      "description": "This license explicitly states that it does NOT grant you any rights in the patents of contributors.",
      "label": "Patent Use"
    }
  ],
  "conditions": [
    {
      "tag": "include-copyright",
      "description": "Include a copy of the license and copyright notice with the code.",
      "label": "License and Copyright Notice"
    },
    {
      "tag": "document-changes",
      "description": "Indicate significant changes made to the code.",
      "label": "State Changes"
    },
    {
      "tag": "disclose-source",
      "description": "Source code must be made available when distributing the software.",
      "label": "Disclose Source"
    },
    {
      "tag": "network-use-disclose",
      "description": "Users who interact with the software via network are given the right to receive a copy of the corresponding source code.",
      "label": "Network Use is Distribution"
    },
    {
      "tag": "rename",
      "description": "You must change the name of the software if you modify it.",
      "label": "Rename"
    },
    {
      "tag": "same-license",
      "description": "Modifications must be released under the same license when distributing the software. In some cases a similar or related license may be used.",
      "label": "Same License"
    }
  ],
  "permissions": [
    {
      "tag": "commercial-use",
      "description": "This software and derivatives may be used for commercial purposes.",
      "label": "Commercial Use"
    },
    {
      "tag": "modifications",
      "description": "This software may be modified.",
      "label": "Modification"
    },
    {
      "tag": "distribution",
      "description": "You may distribute this software.",
      "label": "Distribution"
    },
    {
      "tag": "private-use",
      "description": "You may use and modify the software without distributing it.",
      "label": "Private Use"
    },
    {
      "tag": "patent-use",
      "description": "This license provides an express grant of patent rights from the contributor to the recipient.",
      "label": "Patent Use"
    }
  ]
}
