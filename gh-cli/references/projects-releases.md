# gh project / gh release — Projects and Releases

## Projects (gh project)

### List / View / Create / Edit / Delete

```bash
gh project list
gh project list --owner owner --open

gh project view 123
gh project view 123 --format json --web

gh project create --title "My Project"
gh project create --title "Project" --org orgname --readme "Description here"

gh project edit 123 --title "New Title"
gh project close 123
gh project delete 123
gh project copy 123 --owner target-owner --title "Copy"
gh project mark-template 123
```

### Fields

```bash
gh project field-list 123
gh project field-create 123 --title "Status" --datatype single_select
gh project field-delete 123 --id 456
```

### Items

```bash
gh project item-list 123
gh project item-create 123 --title "New item"
gh project item-add 123 --owner-owner --repo repo --issue 456
gh project item-edit 123 --id 456 --title "Updated title"
gh project item-delete 123 --id 456
gh project item-archive 123 --id 456
```

### Link / Unlink

```bash
gh project link 123 --id 456 --link-id 789
gh project unlink 123 --id 456 --link-id 789
```

---

## Releases (gh release)

### List / View

```bash
gh release list
gh release view              # latest
gh release view v1.0.0
gh release view v1.0.0 --web
```

### Create / Edit / Delete

```bash
gh release create v1.0.0 --notes "Release notes here"
gh release create v1.0.0 --notes-file notes.md --target main
gh release create v1.0.0 --draft --prerelease --title "Version 1.0.0"

gh release edit v1.0.0 --notes "Updated notes"

gh release delete v1.0.0 --yes
gh release delete-asset v1.0.0 file.tar.gz
```

### Assets — Upload / Download

```bash
gh release upload v1.0.0 ./file.tar.gz
gh release upload v1.0.0 ./file1.tar.gz ./file2.tar.gz

gh release download v1.0.0
gh release download v1.0.0 --pattern "*.tar.gz" --dir ./downloads
gh release download v1.0.0 --archive zip
```

### Verify

```bash
gh release verify v1.0.0
gh release verify-asset v1.0.0 file.tar.gz
```
