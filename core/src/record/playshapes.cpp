// playshapes.cpp
// Copyright (c) 2013, Zhang Yungui
// License: LGPL, https://github.com/rhcad/touchvg

#include "playshapes.h"
#include "mgshapedoc.h"
#include "spfactoryimpl.h"
#include "mgjsonstorage.h"
#include "mgstorage.h"
#include "mglog.h"
#include <sstream>

struct MgPlayShapes::Impl
{
    std::string     path;
    GiTransform     xform;
    
    MgShapeDoc      *frontDoc;
    MgShapeDoc      *backDoc;
    MgShapes        *dynShapes;
    
    MgShapeFactoryImpl  factory;
    
    Impl(GiTransform* xf) : xform(*xf) {
        frontDoc = MgShapeDoc::createDoc();
        backDoc = MgShapeDoc::createDoc();
        dynShapes = MgShapes::create();
    }
    
    ~Impl() {
        frontDoc->release();
        backDoc->release();
        dynShapes->release();
    }
    
    void loadNextFile(MgShapes* shapes, MgStorage* s);
};

MgPlayShapes::MgPlayShapes(const char* path, GiTransform* xform)
{
    _im = new Impl(xform);
    _im->path = path;
    if (*_im->path.rbegin() != '/' && *_im->path.rbegin() != '\\') {
        _im->path += '/';
    }
}

MgPlayShapes::~MgPlayShapes()
{
    delete _im;
}

bool MgPlayShapes::loadFirstFile()
{
    std::stringstream ss;
    ss << _im->path << "0.vg";
    
    FILE *fp = mgopenfile(ss.str().c_str(), "rt");
    MgJsonStorage storage;
    MgStorage* s = storage.storageForRead(fp);
    
    if (fp) {
        fclose(fp);
    } else {
        LOGE("Fail to open file: %s", ss.str().c_str());
        return false;
    }
    
    return _im->frontDoc->loadAll(&_im->factory, s, &_im->xform);
}

void MgPlayShapes::copyXform(GiTransform* xform)
{
    xform->copy(_im->xform);
}

MgShapeDoc* MgPlayShapes::pickFrontDoc()
{
    MgShapeDoc* doc = MgShapeDoc::createDoc();
    doc->copyShapes(_im->frontDoc, false);
    return doc;
}

MgShapes* MgPlayShapes::pickDynShapes()
{
    MgShapes* ret = MgShapes::create();
    ret->copyShapes(_im->dynShapes, false);
    return ret;
}

int MgPlayShapes::loadNextFile(int index)
{
    std::stringstream ss;
    ss << _im->path << index << ".vgr";
    
    FILE *fp = mgopenfile(ss.str().c_str(), "rt");
    MgJsonStorage storage;
    MgStorage* s = storage.storageForRead(fp);
    int ret = 0;
    
    if (fp) {
        fclose(fp);
    } else {
        LOGD("Fail to open file: %d.vgr", index);
        return 0;
    }
    
    if (s && s->readNode("record", -1, false)) {
        if (s->readInt("updateFlags", 0)) {
            ret |= STATIC_CHANGED;
            _im->backDoc->copyShapes(_im->frontDoc, false);
            _im->loadNextFile(_im->backDoc->getCurrentShapes(), s);
            
            MgShapeDoc* tmp = _im->frontDoc;
            _im->frontDoc = _im->backDoc;
            _im->backDoc = tmp;
        }
        
        if (s->readNode("dynamic", -1, false)) {
            ret |= _im->dynShapes->load(&_im->factory, s) ? DYNAMIC_CHANGED : 0;
            s->readNode("dynamic", -1, true);
        }
        
        ret |= (s->readInt("tick", 0) & TICKMASK);
        s->readNode("record", -1, true);
    }
    
    return ret;
}

void MgPlayShapes::Impl::loadNextFile(MgShapes* shapes, MgStorage* s)
{
    if (s->readInt("updateFlags", 0) & (ADD | EDIT)) {
        shapes->load(&factory, s, true);    // append or update
    }
    if (s->readNode("delete", -1, false)) {
        for (int i = 0, index = 0; ; i++) {
            std::stringstream ss;
            ss << "d" << index++;
            int sid = s->readInt(ss.str().c_str(), 0);
            if (sid == 0)
                break;
            MgShape* sp = shapes->removeShape(sid, false);
            MgObject::release(sp);
        }
        s->readNode("delete", -1, true);
    }
}
